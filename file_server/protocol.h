#include <stdio.h>
#include <stdlib.h>
#include <arpa/inet.h>

#ifndef __PROTOCOL_H
#define __PROTOCOL_H

int read_client_request(FILE * fp, char ** user, char ** pass, char ** path, long long * initial);

int respond_error(FILE * fp, int code, const char * message);
int respond_success(FILE * fp);
int respond_send_data(FILE * fp, const void * data, size_t length);

#endif
