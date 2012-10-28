//
//  scgi.h
//  SCGITesting
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#ifndef SCGITesting_scgi_h
#define SCGITesting_scgi_h

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

char * netstring_encode(const char * buffer, size_t length, size_t * lengthOut);

/**
 * A structure use to represent the fields passed to a SCGI
 * program by the web server.
 */
typedef struct {
    char ** fields;
    char ** values;
    int field_count;
    int alloc_count;
} SCGIFields;

/**
 * Create a new set of SCGI fields.
 */
SCGIFields * scgi_fields_alloc();

/**
 * Returns the number of key/value pairs in some fields.
 */
int scgi_fields_count(SCGIFields * fields);

/**
 * Get the key at a given index in the SCGI fields
 */
const char * scgi_fields_get_key(SCGIFields * fields, int index);

/**
 * Get the value at a given index in the SCGI fields
 */
const char * scgi_fields_get_value(SCGIFields * fields, int index);

/**
 * Add a key/value pair to the fields.
 * @param fields The fields
 * @param key The key, which will be copied into a buffer owned by the fields
 * @param value The value, which will be copied into a buffer owned by the fields
 */
void scgi_fields_add(SCGIFields * fields, const char * key, const char * value);

/**
 * Encode the SCGI fields in the format specified by the SCGI standard.
 */
char * scgi_fields_encode(SCGIFields * fields, size_t * lengthOut);

/**
 * Releases all memory resources belonging to a set of fields.
 */
void scgi_fields_free(SCGIFields * fields);

#endif

