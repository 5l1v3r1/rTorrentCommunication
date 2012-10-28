//
//  ANRTorrentStart.m
//  RTorrentControl
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANRTorrentStart.h"

@implementation ANRTorrentStart

@synthesize hash;

- (id)initWithHash:(NSString *)aHash {
    if ((self = [super init])) {
        hash = aHash;
    }
    return self;
}

- (NSArray *)encodeRequests {
    XMLRPCRequest * request = [[XMLRPCRequest alloc] initWithURL:nil];
    [request setMethod:@"d.start" withParameters:@[[hash uppercaseString]]];
    return @[request];
}

- (id)responseObject:(NSArray *)responses {
    return nil;
}

@end
