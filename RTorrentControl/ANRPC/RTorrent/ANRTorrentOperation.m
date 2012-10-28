//
//  ANRTorrentOperation.m
//  iRTorrent
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANRTorrentOperation.h"

@implementation ANRTorrentOperation

@synthesize type;
@synthesize arguments;

- (id)initWithOperation:(ANRTorrentOperationType)operation arguments:(NSArray *)args {
    if ((self = [super init])) {
        type = operation;
        arguments = args;
    }
    return self;
}

- (NSArray *)encodeRequests {
    XMLRPCRequest * request = [[XMLRPCRequest alloc] initWithURL:nil];
    if (type == ANRTorrentOperationList) {
        NSString * view = [arguments objectAtIndex:0];
        NSString * viewStr = view && [view isKindOfClass:[NSString class]] ? view : @"main";
        [request setMethod:@"d.multicall" withParameters:@[viewStr, @"d.get_hash=", @"d.get_directory=", @"d.get_base_path=", @"d.get_completed_bytes=", @"d.get_size_bytes=", @"d.get_name=", @"d.get_up_rate=", @"d.get_down_rate=", @"d.get_up_total=", @"d.get_down_total=", @"d.get_state="]];
    } else {
        NSArray * names = @[@"d.erase", @"load", @"d.start", @"d.stop"];
        NSString * name = [names objectAtIndex:type];
        [request setMethod:name withParameters:arguments];
    }
    return @[request];
}

- (id)responseObject:(NSArray *)responses {
    if (type == ANRTorrentOperationList) {
        NSArray * lists = [[responses lastObject] object];
        NSMutableArray * infos = [[NSMutableArray alloc] initWithCapacity:[lists count]];
        for (NSArray * list in lists) {
            ANRTorrentInfo * info = [[ANRTorrentInfo alloc] initWithArray:list];
            [infos addObject:info];
        }
        return infos;
    } else {
        return [[responses lastObject] object];
    }
}

@end
