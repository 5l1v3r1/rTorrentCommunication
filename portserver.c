#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <stdio.h>

int main(int argc, const char * argv[]) {
    int port = atoi(argv[1]);
    struct sockaddr_in local, remote;
    int server, client;
    if ((server = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        perror("socket");
        return 1;
    }
    local.sin_family = AF_INET;
    local.sin_addr.s_addr = INADDR_ANY;
    local.sin_port = htons(port);
    if (bind(server, (struct sockaddr *)&local, sizeof(local)) < 0) {
        perror("bind");
        return 1;
    }
    printf("***WAITING***\n");
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
            int c = fgetc(fp);
            if (c == EOF) break;
            printf("%c", (char)c);
            fflush(stdout);
        }
        fclose(fp);
        printf("\n***DONE***\n");
    }
    return 0;
}
