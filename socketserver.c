#include <sys/socket.h>
#include <sys/un.h>
#include <sys/types.h>
#include <stdio.h>

int main(int argc, const char * argv[]) {
    struct sockaddr_un local, remote;
    int server, client;
    if ((server = socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
        perror("socket");
        return 1;
    }
    local.sun_family = AF_UNIX;
    strcpy(local.sun_path, "test.socket");
    unlink("test.socket"); // hmm
    if (bind(server, (struct sockaddr *)&local, strlen(local.sun_path) + sizeof(local.sun_family)) < 0) {
        perror("bind");
        return 1;
    }
    printf("***WAITING***");
    listen(server, 5);
    while (1) {
        int x = sizeof(remote);
        client = accept(server, (struct sockaddr *)&remote, &x);
        if (client < 0) {
            perror("accept");
            return 0;
        }
        printf("***CONNECTED***\n");
        FILE * fp = fdopen(client, "r");
        while (!feof(fp)) {
            char buff[512];
            buff[0] = 0;
            fgets(buff, 512, fp);
            printf("%s", buff);
        }
        fclose(fp);
        printf("\n***DONE***\n");
    }
    return 0;
}
