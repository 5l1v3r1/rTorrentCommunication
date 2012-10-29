#include <stdio.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include "protocol.h"

void handle_client(int fd, const char * user, const char * pass);

int main(int argc, const char * argv[]) {
    if (argc != 4) {
        fprintf(stderr, "Usage: %s username password port\n", argv[0]);
        return 1;
    }
    int server = socket(AF_INET, SOCK_STREAM, 0);
    if (server < 0) {
        perror("socket");
        return 1;
    }
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(atoi(argv[3]));
    addr.sin_addr.s_addr = INADDR_ANY;
    if (bind(server, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        perror("bind");
    }
    listen(server, 5);
    while (1) {
        int client = accept(server);
        if (client < 0) {
            perror("accept");
            return 1;
        }
        if (fork()) {
            close(client);
        } else {
            handle_client(client, argv[1], argv[2]);
            exit(0);
        }
    }
    return 0;
}

void handle_client(int fd, const char * userTest, const char * passTest) {
    FILE * fp = fdopen(fd, "w+");
    char * user, * pass, * path;
    long long initial;
    if (read_client_request(fp, &user, &pass, &path, &initial) < 0) {
        return;
    }
    
    fclose(fp);
}
