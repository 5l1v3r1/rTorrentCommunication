#ifndef CLIENT_PROTOCOL_H
#define CLIENT_PROTOCOL_H

#include "KBCKit/KBCKit.h"

int client_protocol_read_request(int fd, char ** user, char ** pass, void ** xml, size_t * xml_len);
int client_protocol_write_response(int fd, const void * buffer, size_t length);

#endif