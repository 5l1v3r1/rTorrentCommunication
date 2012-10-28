#include <sys/un.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <stdio.h>
#include "scgi.h"

#define ADDR_FILE "/root/rtorrent.socket"

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

int main(int argc, const char * argv[]) {
    struct sockaddr_un addr;
    int fd;
    if ((fd = socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
        return 1;
    }
    addr.sun_family = AF_UNIX;
    strcpy(addr.sun_path, ADDR_FILE);
    int len = strlen(ADDR_FILE) + sizeof(addr.sun_family);
    if (connect(fd, (struct sockaddr *)&addr, len) < 0) {
        fprintf(stderr, "Couldn't connect to the socket.\n");
        return 1;
    }
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
