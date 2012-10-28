#include <sys/un.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <stdio.h>
#include "scgi.h"

#define ADDR_FILE "rtorrent.socket"

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
char * message = "<?xml version=\"1.0\"?>\r\n\
<methodCall>\r\n\
   <methodName>examples.getStateName</methodName>\r\n\
   <params>\r\n\
      <param>\r\n\
         <value><i4>41</i4></value>\r\n\
         </param>\r\n\
      </params>\r\n\
   </methodCall>";
    /*printf("%s", body);
    FILE * fp = fdopen(fd, "r+");
    int wrote = fwrite(body, 1, strlen(body), fp);
    fflush(fp);
    printf("wrote %d\n", wrote);
    sleep(1);
    while (!feof(fp)) {
        char buff[512];
        buff[0] = 0;
        fgets(buff, 512, fp);
        printf("%s", buff);
    }
    fclose(fp);*/
    send(fd, body, strlen(body), 0);
    char buff[512];
    buff[0] = 0;
    int l = recv(fd, buff, 512, 0);
    printf("%s %d", buff, l);
    return 0;
}
