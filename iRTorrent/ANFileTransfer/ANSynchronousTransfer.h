//
//  ANSynchronousTransfer.h
//  iRTorrent
//
//  Created by Alex Nichol on 10/29/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

@interface ANSynchronousTransfer : NSObject {
    NSString * host;
    UInt16 port;
    FILE * fp;
}

- (id)initWithHost:(NSString *)aHost port:(UInt16)aPort;

- (BOOL)connect;
- (BOOL)sendUsername:(NSString *)username password:(NSString *)password path:(NSString *)path initial:(long long)off;
- (NSNumber *)readResponse:(NSError **)error;
- (NSNumber *)readBlockToFile:(NSFileHandle *)destination;
- (void)close;

@end
