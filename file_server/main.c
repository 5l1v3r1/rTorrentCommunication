#ifdef __linux__
#define __USE_LARGEFILE64
#define _LARGEFILE_SOURCE
#define _LARGEFILE64_SOURCE
#endif

#include <stdio.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <signal.h>
#include <wait.h>
#include "protocol.h"

void handle_client(int fd, const char * user, const char * pass);
void sigchild_handler(int sigNum);

int main(int argc, const char * argv[]) {
    if (argc != 4) {
        fprintf(stderr, "Usage: %s username password port\n", argv[0]);
        return 1;
    }
    // setup signal handler
    struct sigaction sa;
    bzero(&sa, sizeof(sa));
    sa.sa_handler = &sigchild_handler;
    sigaction(SIGCHLD, &sa, NULL);
    // setup server socket
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
        int client = accept(server, NULL, NULL);
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
    if (strcmp(user, userTest) != 0 || strcmp(pass, passTest) != 0) {
        respond_error(fp, PROTOCOL_ERROR_AUTH, "Login incorrect.");
        goto handleError;
    }
#ifdef __linux__
    struct stat64 info;
    if (stat64(path, &info) < 0) {
#else
    struct stat info
    if (stat(path, &info) < 0) {
#endif
        respond_error(fp, PROTOCOL_ERROR_NO_FILE, "Could not stat file.");
        goto handleError;
    }
    if (S_ISDIR(info.st_mode)) {
        respond_error(fp, PROTOCOL_ERROR_NOT_FILE, "Could not send directory.");
        goto handleError;
    }
    if (initial > info.st_size) {
        respond_error(fp, PROTOCOL_ERROR_INVALID_INITIAL, "Invalid initial offset.");
        goto handleError;
    }
#ifdef __linux__
    FILE * readFile = fopen64(path, "r");
#else
    FILE * readfile = fopen(path, "r");
#endif
    if (!readFile) {
        perror("fopen");
        respond_error(fp, PROTOCOL_ERROR_INTERNAL, "fopen() failed");
        goto handleError;
    }
    
    if (respond_success(fp, info.st_size - initial) < 0) {
        fclose(readFile);
        goto handleError;
    }
    
    // read file from start offset
    fseek(readFile, initial, SEEK_SET);
    char buff[512];
    while (!feof(readFile)) {
        int got = fread(buff, 1, 512, readFile);
        if (got == 0) break;
        if (fwrite(buff, 1, got, fp) != got) {
            break;
        }
    }
    fclose(readFile);
    
handleError:
    fclose(fp);
    free(user);
    free(pass);
    free(path);
    return;
}

void sigchild_handler(int signal) {
    int status;
    wait(&status);
}

