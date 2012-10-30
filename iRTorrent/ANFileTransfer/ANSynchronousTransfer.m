//
//  ANSynchronousTransfer.m
//  iRTorrent
//
//  Created by Alex Nichol on 10/29/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANSynchronousTransfer.h"

@interface ANSynchronousTransfer (Private)

- (BOOL)writeNullTerminated:(NSString *)string;
- (NSString *)readNullTerminated;
- (NSError *)errorWithCode:(int)code message:(NSString *)message;

@end

@implementation ANSynchronousTransfer

- (id)initWithHost:(NSString *)aHost port:(UInt16)aPort {
    if ((self = [super init])) {
        host = aHost;
        port = aPort;
    }
    return self;
}

- (BOOL)connect {
    struct hostent * ent = gethostbyname([host UTF8String]);
    if (!ent) return NO;
    if (ent->h_addrtype == AF_INET) {
        struct sockaddr_in addr;
        bzero(&addr, sizeof(addr));
        addr.sin_family = AF_INET;
        addr.sin_port = htons(port);
        memcpy(&addr.sin_addr.s_addr, ent->h_addr_list[0], sizeof(addr.sin_addr.s_addr));
        int fd = socket(AF_INET, SOCK_STREAM, 0);
        if (fd < 0) return NO;
        if (connect(fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
            close(fd);
            return NO;
        }
        fp = fdopen(fd, "r+");
    } else if (ent->h_addrtype == AF_INET6) {
        struct sockaddr_in6 addr;
        bzero(&addr, sizeof(addr));
        addr.sin6_family = AF_INET6;
        addr.sin6_port = htons(port);
        memcpy(&addr.sin6_addr, ent->h_addr_list[0], sizeof(addr.sin6_addr));
        int fd = socket(AF_INET6, SOCK_STREAM, 0);
        if (fd < 0) return NO;
        if (connect(fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
            close(fd);
            return NO;
        }
        fp = fdopen(fd, "r+");
    } else {
        return NO;
    }
    return YES;
}

- (BOOL)sendUsername:(NSString *)username password:(NSString *)password path:(NSString *)path initial:(long long)off {
    if (![self writeNullTerminated:username]) return NO;
    if (![self writeNullTerminated:password]) return NO;
    if (![self writeNullTerminated:path]) return NO;
    if (![self writeNullTerminated:[NSString stringWithFormat:@"%lld", off]]) return NO;
    return YES;
}

- (NSNumber *)readResponse:(NSError **)error {
    int c = fgetc(fp);
    if (c == EOF) {
        *error = [self errorWithCode:EREMOTE message:@"Failed to read from socket"];
        return nil;
    }
    if (c != 0) {
        NSString * errorStr = [self readNullTerminated];
        if (!errorStr) {
            if (error) *error = [self errorWithCode:c message:@"Unknown server error"];
        } else {
            if (error) *error = [self errorWithCode:c message:errorStr];
        }
        return nil;
    }
    NSString * lenStr = [self readNullTerminated];
    if (!lenStr) {
        *error = [self errorWithCode:EREMOTE message:@"Failed to read from socket"];
        return nil;
    }
    return [NSNumber numberWithLongLong:[lenStr longLongValue]];
}

- (NSNumber *)readBlockToFile:(NSFileHandle *)destination {
    char buff[512];
    int size = fread(buff, 1, 512, fp);
    if (size == 0 && feof(fp)) return nil;
    [destination writeData:[NSData dataWithBytes:buff length:size]];
    return [NSNumber numberWithInt:size];
}

- (void)close {
    fclose(fp);
    fp = NULL;
}

#pragma mark - Private -

- (BOOL)writeNullTerminated:(NSString *)string {
    const char * buffer = [string UTF8String];
    int length = (int)strlen(buffer);
    if (fwrite(buffer, 1, length + 1, fp) != length + 1) return NO;
    return YES;
}

- (NSString *)readNullTerminated {
    NSMutableString * string = [[NSMutableString alloc] init];
    while (!feof(fp)) {
        int c = fgetc(fp);
        if (c == EOF || c == 0) break;
        [string appendFormat:@"%c", (char)c];
    }
    if (feof(fp)) return nil;
    return [string copy];
}

- (NSError *)errorWithCode:(int)code message:(NSString *)message {
    return [NSError errorWithDomain:@"ANSynchronousTransfer"
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey: message}];
}

@end
