#include <sys/un.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <stdio.h>
#include <netdb.h>
#include "scgi.h"
#include "client_protocol.h"

int server_main_loop(int serverMethod, int server, int localMethod, const char * localSource);
void handle_client(int client, int localMethod, const char * localSource);

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
        } else {
            fprintf(stderr, "Unknown option: %s\n", argv[i]);
            exit(1);
        }
    }
    int server = listen_method(listenMethod, listenSource, allowRemote);
    if (server < 0) exit(1);
    return server_main_loop(listenMethod, server, localMethod, localSource);
}

int server_main_loop(int serverMethod, int server, int localMethod, const char * localSource) {
    while (1) {
        int client = accept_method(serverMethod, server);
        if (client < 0) {
            return 1;
        }
        if (fork()) {
            close(client);
        } else {
            handle_client(client, localMethod, localSource);
        }
    }
    return 0;
}

void handle_client(int client, int localMethod, const char * localSource) {
    char * username, * password;
    void * xmlBuffer;
    size_t xmlLength;
    if (client_protocol_read_request(client, &username, &password, &xmlBuffer, &xmlLength) < 0) {
        close(client);
        fprintf(stderr, "error: invalid client request\n");
        return;
    }
    // TODO: open the socket here and read the data from it
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
