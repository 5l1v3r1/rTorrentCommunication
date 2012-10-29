#include "protocol.h"

static char * read_until_null(FILE * fp);

int read_client_request(FILE * fp, char ** user, char ** pass, char ** path, long long * initial) {
    *user = read_until_null(fp);
    if (!*user) {
        fclose(fp);
        fprintf(stderr, "failed to read user\n");
        return -1;
    }
    *pass = read_until_null(fp);
    if (!*pass) {
        fclose(fp);
        free(*user);
        fprintf(stderr, "failed to read pass\n");
        return -1;
    }
    *path = read_until_null(fp);
    if (!*path) {
        fclose(fp);
        free(*user);
        free(*pass);
        fprintf(stderr, "failed to read path\n");
        return -1;
    }
    char * initialStr = read_until_null(fp);
    if (!initialStr) {
        fclose(fp);
        free(*user);
        free(*pass);
        free(*path);
        fprintf(stderr, "failed to read length\n");
        return -1;
    }
    *initial = atoll(initialStr);
    free(initialStr);
    return 0;
}

int respond_error(FILE * fp, int code, const char * message) {
    unsigned char statByte = (unsigned char)code;
    size_t messageLen = strlen(message) + 1;
    if (fwrite(&statByte, 1, 1, fp) != 1) return -1;
    if (fwrite(message, 1, messageLen, fp) != messageLen) return -1;
    return 1 + messageLen;
}

int respond_success(FILE * fp, long long length) {
    char str[32];
    fprintf(str, "%llu", length);
    return respond_error(fp, 0, str);
}

static char * read_until_null(FILE * fp) {
    int len = 0;
    char * buff = malloc(1);
    while (!feof(fp)) {
        int c = fgetc(fp);
        if (c == EOF || c == 0) break;
        buff = realloc(buff, len + 2);
        buff[len++] = (char)c;
    }
    if (feof(fp)) {
        free(buff);
        return NULL;
    }
    buff[len] = 0;
    return buff;
}
