#include <sys/un.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <stdio.h>
#include "scgi.h"

char * generate_request(const char * body, size_t * lengthOut);
int connect_socket(const char * socketPath);

int main(int argc, const char * argv[]) {
    int listenMethod = 0; // method 0 = inet socket, method 1 = unix socket
    char * listenSource = NULL; // method 0 = port number, method 1 = unix path
    char * localMethod = 0; // see listenMethod
    char * localSource = NULL; // see listenSource
    
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

int connect_socket(const char * socketPath) {
    struct sockaddr_un addr;
    int fd;
    if ((fd = socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
        perror("socket");
        return -1;
    }
    addr.sun_family = AF_UNIX;
    strcpy(addr.sun_path, socketPath);
    int len = strlen(socketPath) + sizeof(addr.sun_family);
    if (connect(fd, (struct sockaddr *)&addr, len) < 0) {
        perror("connect");
        return -1;
    }
    return fd;
}

int main(int argc, const char * argv[]) {
    char * body = "<?xml version=\"1.0\"?>\r\n\
<methodCall>\r\n\
   <methodName>system.listMethods</methodName>\r\n\
   <params></params>\r\n\
   </methodCall>";
    FILE * fp = fdopen(fd, "r+");
    size_t length;
    char * sendBuffer = generate_request(body, &length);
    int wrote = fwrite(sendBuffer, 1, length, fp);
    fflush(fp);
    printf("wrote %d\n", wrote);
    while (!feof(fp)) {
        char buff[512];
        buff[0] = 0;
        fgets(buff, 512, fp);
        printf("%s", buff);
    }
    fclose(fp);
    return 0;
}
