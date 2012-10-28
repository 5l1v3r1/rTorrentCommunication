//
//  ANRTorrentInfo.m
//  RTorrentControl
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANRTorrentInfoList.h"

@implementation ANRTorrentInfoList

- (id)initWithView:(NSString *)aView; {
    if ((self = [super init])) {
        view = aView;
    }
    return self;
}

- (NSArray *)encodeRequests {
    XMLRPCRequest * request = [[XMLRPCRequest alloc] initWithURL:nil];
    NSString * viewStr = view ? view : @"main";
    [request setMethod:@"d.multicall" withParameters:@[viewStr, @"d.get_hash=", @"d.get_directory=", @"d.get_base_path=", @"d.get_completed_bytes=", @"d.get_size_bytes=", @"d.get_name=", @"d.get_up_rate=", @"d.get_down_rate=", @"d.get_up_total=", @"d.get_down_total=", @"d.get_state="]];
    return @[request];
}

- (id)responseObject:(NSArray *)responses {
    NSArray * lists = [[responses lastObject] object];
    NSMutableArray * infos = [[NSMutableArray alloc] initWithCapacity:[lists count]];
    for (NSArray * list in lists) {
        ANRTorrentInfo * info = [[ANRTorrentInfo alloc] initWithArray:list];
        [infos addObject:info];
    }
    return infos;
}

@end
