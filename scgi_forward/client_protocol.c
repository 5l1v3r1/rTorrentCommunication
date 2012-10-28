#include "client_protocol.h"

int client_protocol_read_request(int fd, char ** user, char ** pass, void ** xml, size_t * xml_len) {
    KBContextRef context = kb_context_create_file(fd);
    uint8_t type, typeNumber;
    int hasUser = 0, hasPass = 0, hasXml = 0;
    
    if (!kb_decode_read_type(context, &type, &typeNumber)) goto failureHandler;
    // ensure dictionary type
    if (typeNumber != 3) {
        goto failureHandler;
    }
    
    while (1) {
        char * userKey = NULL;
        uint8_t subType = 0, subTypeNumber = 0;
        if (!kb_decode_dictionary_key(context, type, &userKey)) {
            goto failureHandler;
        }
        if (!userKey) break;
        if (strcmp(userKey, "xml") == 0 && !hasXml) {
            free(userKey);
            // read data
            if (!kb_decode_read_type(context, &subType, &subTypeNumber)) {
                goto failureHandler;
            }
            if (subTypeNumber != 5) goto failureHandler; // ensure data
            size_t dataLen = 0;
            void * buffer = kb_decode_data(context, subType, xml_len);
            if (!buffer) {
                goto failureHandler;
            }
            *xml = buffer;
            hasXml = 1;
        } else if ((strcmp(userKey, "user") == 0 && !hasUser) || (strcmp(userKey, "pass") == 0 && !hasPass)) {
            int isUserKey = strcmp(userKey, "user") == 0;
            free(userKey);
            // read string
            if (!kb_decode_read_type(context, &subType, &subTypeNumber)) {
                goto failureHandler;
            }
            if (subTypeNumber != 1) {
                goto failureHandler;
            }
            char * buffer = kb_decode_string(context, subType);
            if (!buffer) {
                goto failureHandler;
            }
            if (isUserKey) {
                *user = buffer;
                hasUser = 1;
            } else {
                *pass = buffer;
                hasPass = 1;
            }
        } else {
            free(userKey);
            goto failureHandler;
        }
    }
    if (!hasUser || !hasPass || !hasXml) {
        goto failureHandler;
    }
    kb_context_free(context);
    return 0;
failureHandler:
    kb_context_free(context);
    if (hasUser) free(*user);
    if (hasPass) free(*pass);
    if (hasXml) free(*xml);
    return -1;
}

int client_protocol_write_response(int fd, const void * buffer, size_t length) {
    KBContextRef context = kb_context_create_file(fd);
    kb_encode_data(context, buffer, length);
    kb_context_free(context);
    return 0;
}
