#include <stdio.h>
#include <stdlib.h>
#include <arpa/inet.h>
#include <string.h>

#ifndef __PROTOCOL_H
#define __PROTOCOL_H

#define PROTOCOL_ERROR_NO_FILE 1
#define PROTOCOL_ERROR_NOT_FILE 2
#define PROTOCOL_ERROR_INVALID_INITIAL 3
#define PROTOCOL_ERROR_INTERNAL 4
#define PROTOCOL_ERROR_AUTH 5

int read_client_request(FILE * fp, char ** user, char ** pass, char ** path, long long * initial);

int respond_error(FILE * fp, int code, const char * message);
int respond_success(FILE * fp, long long totalLength);

#endif
