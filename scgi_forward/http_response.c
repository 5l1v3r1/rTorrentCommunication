#include "http_response.h"

static char * _read_line(FILE * fp);
static int _find_status_code(const char * str);

int http_response_read(FILE * fp, int * statusCode, int * contentLength) {
    while (1) {
        char * value = NULL;
        char * key = NULL;
        int result = http_response_next_header(fp, &key, &value);
        if (result < 0) return -1;
        if (result == 1) break;
        if (strcasecmp(key, "status") == 0) {
            if (statusCode) *statusCode = _find_status_code(value);
        } else if (strcasecmp(key, "content-length") == 0) {
            if (contentLength) *contentLength = atoi(value);
        }
        free(key);
        free(value);
    }
    return 0;
}

/**
 * Read an HTTP header.
 * @return 0 if a header was read, 1 for an empty line, or -1 on error
 */
int http_response_next_header(FILE * fp, char ** keyOut, char ** valueOut) {
    int ch = 0, waitingSpace = 0, keyLen = 0;
    char * key = (char *)malloc(1);
    while ((ch = fgetc(fp)) != EOF) {
        if (ch == '\r') continue;
        else if (ch == '\n') {
            free(key);
            if (keyLen > 0) {
                return -1;
            } else {
                return 1;
            }
        } else if (ch == ':' && !waitingSpace) waitingSpace = 1;
        else if (waitingSpace && ch == ' ') break;
        else {
            key = realloc(key, keyLen + 2);
            key[keyLen++] = (char)ch;
        }
    }
    if (ch == EOF) {
        free(key);
        return -1;
    }
    key[keyLen] = 0;
    *keyOut = key;
    *valueOut = _read_line(fp);
}

static char * _read_line(FILE * fp) {
    int i = 0, len = 0;
    char * buffer = (char *)malloc(1);
    while ((i = fgetc(fp)) != EOF) {
        if (i == '\r') continue;
        else if (i == '\n') break;
        else {
            buffer = realloc(buffer, len + 2);
            buffer[len++] = (char)i;
        }
    }
    buffer[len] = 0;
    return buffer;
}

static int _find_status_code(const char * str) {
    char * newStr = (char *)malloc(strlen(str) + 1);
    int i;
    for (i = 0; i < strlen(str); i++) {
        if (str[i] == ' ') break;
        newStr[i] = str[i];
        newStr[i + 1] = 0;
    }
    int stat = atoi(newStr);
    free(newStr);
    return stat;
}
