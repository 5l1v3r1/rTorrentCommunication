//
//  scgi.c
//  SCGITesting
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#include "scgi.h"

char * netstring_encode(const char * buffer, size_t length, size_t * lengthOut) {
    char lengthStr[16];
    sprintf(lengthStr, "%lu", (unsigned long)length);
    size_t netLength = 2 + strlen(lengthStr) + length;
    char * netStr = (char *)malloc(netLength);
    strcpy(netStr, lengthStr);
    netStr[strlen(lengthStr)] = ':';
    memcpy(&netStr[strlen(lengthStr) + 1], buffer, length);
    netStr[netLength - 1] = ',';
    *lengthOut = netLength;
    return netStr;
}

// SCGI Fields

SCGIFields * scgi_fields_alloc() {
    SCGIFields * fields = (SCGIFields *)malloc(sizeof(SCGIFields));
    fields->fields = (char **)malloc(sizeof(char *));
    fields->values = (char **)malloc(sizeof(char *));
    fields->alloc_count = 1;
    fields->field_count = 0;
    return fields;
}

int scgi_fields_count(SCGIFields * fields) {
    return fields->field_count;
}

const char * scgi_fields_get_key(SCGIFields * fields, int index) {
    return fields->fields[index];
}

const char * scgi_fields_get_value(SCGIFields * fields, int index) {
    return fields->values[index];
}

void scgi_fields_add(SCGIFields * fields, const char * key, const char * value) {
    if (fields->alloc_count == fields->field_count) {
        fields->alloc_count += 8;
        fields->fields = realloc(fields->fields, fields->alloc_count * sizeof(char *));
        fields->values = realloc(fields->values, fields->alloc_count * sizeof(char *));
    }
    char * newKey = (char *)malloc(strlen(key) + 1);
    char * newValue = (char *)malloc(strlen(value) + 1);
    strcpy(newKey, key);
    strcpy(newValue, value);
    fields->fields[fields->field_count] = newKey;
    fields->values[fields->field_count++] = newValue;
}

char * scgi_fields_encode(SCGIFields * fields, size_t * lengthOut) {
    int length, i, off;
    length = fields->field_count * 2;
    for (i = 0; i < fields->field_count; i++) {
        length += strlen(fields->fields[i]);
        length += strlen(fields->values[i]);
    }
    char * buffer = (char *)malloc(length > 0 ? length : 1);
    off = 0;
    for (i = 0; i < fields->field_count; i++) {
        strcpy(&buffer[off], fields->fields[i]);
        off += strlen(fields->fields[i]) + 1;
        strcpy(&buffer[off], fields->values[i]);
        off += strlen(fields->values[i]) + 1;
    }
    *lengthOut = length;
    return buffer;
}

void scgi_fields_free(SCGIFields * fields) {
    int i;
    for (i = 0; i < fields->field_count; i++) {
        free(fields->fields[i]);
        free(fields->values[i]);
    }
    free(fields->fields);
    free(fields->values);
    free(fields);
}


