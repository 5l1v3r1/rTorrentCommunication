//
//  ANRPCCall.m
//  RTorrentControl
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANRPCConnection.h"

static NSError * createErrnoError(NSString * name);

@implementation ANRPCConnection

- (id)initWithHost:(NSString *)aHost port:(UInt16)aPort username:(NSString *)aUsername password:(NSString *)aPassword request:(NSData *)aRequest {
    if ((self = [super init])) {
        host = aHost;
        port = aPort;
        username = aUsername;
        password = aPassword;
        request = aRequest;
    }
    return self;
}

- (NSData *)callSynchronously:(NSError **)error {
    struct hostent * ent = gethostbyname([host UTF8String]);
    if (!ent) {
        if (error) *error = createErrnoError(@"gethostbyname");
        return nil;
    }
    if (ent->h_addrtype != AF_INET) {
        if (error) *error = [NSError errorWithDomain:@"ANRPCConnection"
                                                code:1
                                            userInfo:@{NSLocalizedDescriptionKey: @"AF_INET is the only type supported."}];
        return nil;
    }
    
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_port = htons(port);
    address.sin_family = AF_INET;
    memcpy(&address.sin_addr.s_addr, ent->h_addr_list[0], sizeof(address.sin_addr.s_addr));
    int fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0) {
        if (error) *error = createErrnoError(@"socket");
        return nil;
    }
    if (connect(fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        if (error) *error = createErrnoError(@"connect");
        return nil;
    }
    NSDictionary * dict = @{@"user": username, @"pass": password, @"xml": request};
    kb_encode_full_fd(dict, fd);
    NSObject * response = kb_decode_full_fd(fd);
    close(fd);
    if (![response isKindOfClass:[NSData class]] || !response) {
        if (error) *error = [NSError errorWithDomain:@"ANRPCConnection"
                                                code:2
                                            userInfo:@{NSLocalizedDescriptionKey: @"Failed to read proper response"}];
        return nil;
    }
    return (NSData *)response;
}

@end

static NSError * createErrnoError(NSString * name) {
    NSString * errorStr = [NSString stringWithUTF8String:strerror(errno)];
    if (!errorStr) errorStr = @"Unknown error";
    return [NSError errorWithDomain:name
                               code:errno
                           userInfo:@{NSLocalizedDescriptionKey: errorStr}];
}
