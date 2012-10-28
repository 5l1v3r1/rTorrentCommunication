//
//  ANRTorrentLoad.m
//  RTorrentControl
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANRTorrentLoad.h"

@implementation ANRTorrentLoad

@synthesize torrentURL;

- (id)initWithURL:(NSURL *)url {
    if ((self = [super init])) {
        torrentURL = url;
    }
    return self;
}

- (NSArray *)encodeRequests {
    XMLRPCRequest * request = [[XMLRPCRequest alloc] initWithURL:nil];
    [request setMethod:@"load" withParameter:[torrentURL absoluteString]];
    return @[request];
}

- (id)responseObject:(NSArray *)responses {
    return nil;
}

@end
