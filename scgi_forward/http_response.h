#ifndef HTTP_RESPONSE_H
#define HTTP_RESPONSE_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int http_response_read(FILE * fp, int * statusCode, int * contentLength);
int http_response_next_header(FILE * fp, char ** key, char ** value);

#endif