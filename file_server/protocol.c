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

int respond_success(FILE * fp) {
    if (fwrite("\x00", 1, 1, fp) == 1) return 1;
    return -1;
}

int respond_send_data(FILE * fp, const void * data, size_t length) {
    char sizeData[4];
    if (sizeof(short) == 4) {
        unsigned short n = htons((unsigned short)length);
        memcpy(sizeData, &n, 4);
    } else if (sizeof(int) == 4) {
        unsigned int n = htons((unsigned int)length);
        memcpy(sizeData, &n, 4);
    } else {
        return -1;
    }
    if (fwrite(sizeData, 1, 4, fp) != 4) return -1;
    if (fwrite(data, 1, length, fp) != length) return -1;
    return (int)length + 4;
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
        free(buff) return NULL;
    }
    buff[len] = 0;
    return buff;
}
