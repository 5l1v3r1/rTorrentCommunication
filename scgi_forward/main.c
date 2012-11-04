#include <sys/un.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <stdio.h>
#include <netdb.h>
#include <signal.h>
#include <wait.h>
#include "scgi.h"
#include "client_protocol.h"
#include "http_response.h"

#define AUTH_USER "root"
#define AUTH_PASS "toor"

void print_usage(const char * name);
void sigchild_handler(int sig);

int server_main_loop(int serverMethod, int server, int localMethod, const char * localSource, const char * username, const char * password);
int handle_client(int client, int localMethod, const char * localSource, const char * username, const char * password);

char * generate_request(const char * body, size_t * lengthOut);

int parse_address(const char * str, char * host, int * port);
int listen_method(int method, const char * source, int allowRemote);
int accept_method(int method, int server);
int connect_method(int method, const char * addr);

int main(int argc, const char * argv[]) {
    int listenMethod = -1; // method 0 = inet socket, method 1 = unix socket
    const char * listenSource = NULL; // inet = port number, unix = unix path
    int localMethod = -1; // see listenMethod
    const char * localSource = NULL; // see listenSource
    const char * username = AUTH_USER;
    const char * password = AUTH_PASS;
    int allowRemote = 1;
    int i;
    for (i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--local_unix") == 0) {
            if (i + 1 == argc) {
                fprintf(stderr, "Missing value for --local_unix\n");
                exit(1);
            }
            localMethod = 1;
            localSource = argv[++i];
        } else if (strcmp(argv[i], "--local_host") == 0) {
            if (i + 1 == argc) {
                fprintf(stderr, "Missing value for --local_host\n");
                exit(1);
            }
            localMethod = 0;
            localSource = argv[++i];
        } else if (strcmp(argv[i], "--listen_unix") == 0) {
            if (i + 1 == argc) {
                fprintf(stderr, "Missing value for --listen_unix\n");
                exit(1);
            }
            listenMethod = 1;
            listenSource = argv[++i];
        } else if (strcmp(argv[i], "--listen_port") == 0) {
            if (i + 1 == argc) {
                fprintf(stderr, "Missing value for --listen_port\n");
                exit(1);
            }
            listenMethod = 0;
            listenSource = argv[++i];
        } else if (strcmp(argv[i], "--local") == 0) {
            allowRemote = 0;
        } else if (strcmp(argv[i], "--username") == 0) {
            if (i + 1 == argc) {
                fprintf(stderr, "Missing value for --username");
                exit(1);
            }
            username = argv[++i];
        } else if (strcmp(argv[i], "--password") == 0) {
            if (i + 1 == argc) {
                fprintf(stderr, "Missing value for --password");
                exit(1);
            }
            password = argv[++i];
        } else {
            fprintf(stderr, "Unknown option: %s\n", argv[i]);
            exit(1);
        }
    }
    if (localMethod < 0) {
        print_usage(argv[0]);
        exit(1);
    }
    if (listenMethod < 0) {
        print_usage(argv[0]);
        exit(1);
    }
    // setup sig handler
    struct sigaction sa;
    bzero(&sa, sizeof(sa));
    sa.sa_handler = &sigchild_handler;
    sigaction(SIGCHLD, &sa, NULL);
    // setup server
    int server = listen_method(listenMethod, listenSource, allowRemote);
    if (server < 0) exit(1);
    return server_main_loop(listenMethod, server, localMethod, localSource, username, password);
}

void print_usage(const char * name) {
    fprintf(stderr, "Usage: %s [--listen_unix path | --listen_port port [--local]] [--local_unix path | --local_host host:port] --username user --password pass\n", name);
}

void sigchild_handler(int sig) {
    int status;
    wait(&status);
}

int server_main_loop(int serverMethod, int server, int localMethod, const char * localSource, const char * username, const char * password) {
    while (1) {
        int client = accept_method(serverMethod, server);
        if (client < 0) {
            return 1;
        }
        if (fork()) {
            close(client);
        } else {
            while (1) {
                if (handle_client(client, localMethod, localSource, username, password) < 0) {
                    break;
                }
            }
            exit(0);
        }
    }
    return 0;
}

int handle_client(int client, int localMethod, const char * localSource, const char * usernameRight, const char * passwordRight) {
    char * username, * password;
    void * xmlBuffer;
    size_t xmlLength;
    if (client_protocol_read_request(client, &username, &password, &xmlBuffer, &xmlLength) < 0) {
        close(client);
        fprintf(stderr, "error: invalid client request\n");
        return -1;
    }
    if (strcmp(username, usernameRight) != 0 || strcmp(password, passwordRight) != 0) {
        fprintf(stderr, "error: got incorrect login\n");
        free(username);
        free(password);
        free(xmlBuffer);
        close(client);
        return -1;
    }
    free(username);
    free(password);

    int localClient = connect_method(localMethod, localSource);
    if (localClient < 0) {
        close(client);
        fprintf(stderr, "error: failed to connect locally\n");
        return -1;
    }
    
    char * xmlString = (char *)malloc(xmlLength + 1);
    memcpy(xmlString, xmlBuffer, xmlLength);
    xmlString[xmlLength] = 0;
    free(xmlBuffer);
    size_t requestLength = 0;
    char * request = generate_request(xmlString, &requestLength);
    free(xmlString);
    
    FILE * localFp = fdopen(localClient, "r+");
    fwrite(request, 1, requestLength, localFp);
    free(request);
    
    int statusCode = 0;
    int contentLength = 0;
    if (http_response_read(localFp, &statusCode, &contentLength) < 0) {
        fclose(localFp);
        close(client);
        fprintf(stderr, "error: failed to read response header\n");
        return -1;
    }
    
    char * responseBody = (char *)malloc(contentLength + 1);
    size_t count = fread(responseBody, 1, contentLength, localFp);
    if (count == contentLength) {
        client_protocol_write_response(client, responseBody, count);
    } else {
        fprintf(stderr, "error: failed to read response\n");
    }
    
    fclose(localFp);
    return 0;
}

char * generate_request(const char * body, size_t * lengthOut) {
    char lenStr[16];
    sprintf(lenStr, "%d", (int)strlen(body));
    SCGIFields * fields = scgi_fields_alloc();
    scgi_fields_add(fields, "CONTENT_LENGTH", lenStr);
    scgi_fields_add(fields, "SCGI", "1");
    scgi_fields_add(fields, "REQUEST_METHOD", "POST");
    scgi_fields_add(fields, "REQUEST_URI", "/RPC2");
    size_t length;
    char * encoded = scgi_fields_encode(fields, &length);
    char * netstr = netstring_encode(encoded, length, &length);
    free(encoded);
    scgi_fields_free(fields);
    char * req = realloc(netstr, length + strlen(body));
    memcpy(&req[length], body, strlen(body));
    *lengthOut = length + strlen(body);
    return req;
}

int parse_address(const char * str, char * host, int * port) {
    int i, state = 0, hostLen = 0, portLen = 0;
    char hostStr[32];
    char portStr[8];
    for (i = 0; i < strlen(str); i++) {
        if (str[i] == ':') state ++;
        else if (state == 0) {
            if (hostLen == 31) return -1;
            hostStr[hostLen++] = str[i];
            hostStr[hostLen] = 0;
        } else if (state == 1) {
            if (portLen == 7) return -1;
            portStr[portLen++] = str[i];
            portStr[portLen] = 0;
        }
    }
    if (state == 0) return -1;
    if (host) strcpy(host, hostStr);
    if (port) *port = atoi(portStr);
    return 0;
}

int listen_method(int method, const char * source, int allowRemote) {
    int server;
    if (method == 0) {
        // inet socket
        int port = atoi(source);
        struct sockaddr_in local;
        if ((server = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
            perror("socket");
            return -1;
        }
        local.sin_family = AF_INET;
        local.sin_addr.s_addr = INADDR_ANY; // TODO: allowLocal
        local.sin_port = htons(port);
        if (bind(server, (struct sockaddr *)&local, sizeof(local)) < 0) {
            perror("bind");
            return -1;
        }
    } else {
        // unix socket
        struct sockaddr_un local;
        if (strlen(source) + 1 > sizeof(local.sun_path)) {
            fprintf(stderr, "listen_method: path too long");
            return -1;
        }
        if ((server = socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
            perror("socket");
            return -1;
        }
        local.sun_family = AF_UNIX;
        strcpy(local.sun_path, source);
        if (unlink(source) != 0) {
            perror("unlink");
            return -1;
        }
        int length = strlen(source) + sizeof(local.sun_family);
        if (bind(server, (struct sockaddr *)&local, length) < 0) {
            perror("bind");
            return -1;
        }
    }
    if (listen(server, 5) < 0) {
        perror("listen");
        return -1;
    }
    return server;
}

int accept_method(int method, int server) {
    if (method == 0) {
        // inet socket
        struct sockaddr_in remote;
        int x = sizeof(remote);
        return accept(server, (struct sockaddr *)&remote, &x);
    } else {
        // unix socket
        struct sockaddr_un remote;
        int x = sizeof(remote);
        return accept(server, (struct sockaddr *)&remote, &x);
    }
}

int connect_method(int method, const char * addrStr) {
    if (method == 0) {
        // inet socket
        char hostAddress[32];
        int hostPort = 0;
        if (parse_address(addrStr, hostAddress, &hostPort) != 0) {
            fprintf(stderr, "parse_address: failed\n");
            return -1;
        }
        
        struct sockaddr_in addr;
        struct hostent * ent;
        int fd;
        if ((fd = socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
            perror("socket");
            return -1;
        }
        ent = gethostbyname(hostAddress);
        if (!ent) {
            perror("gethostbyname");
            return -1;
        }
        addr.sin_family = AF_INET;
        addr.sin_port = htons(hostPort);
        memcpy(&addr.sin_addr.s_addr, ent->h_addr, sizeof(addr.sin_addr.s_addr));
        bzero(addr.sin_zero, 8);
        
        if (connect(fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
            perror("connect");
            return -1;
        }
        return fd;
    } else {
        // unix socket
        struct sockaddr_un addr;
        if (strlen(addrStr) + 1 > sizeof(addr.sun_path)) {
            fprintf(stderr, "connect_method: path too long");
            return -1;
        }
        int fd;
        if ((fd = socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
            perror("socket");
            return -1;
        }
        addr.sun_family = AF_UNIX;
        strcpy(addr.sun_path, addrStr);
        int len = sizeof(addr.sun_family) + strlen(addr.sun_path);
        if (connect(fd, (struct sockaddr *)&addr, len) < 0) {
            perror("connect");
            return -1;
        }
        return fd;
    }
}
