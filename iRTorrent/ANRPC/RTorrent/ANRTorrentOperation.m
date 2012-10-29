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
        NSString * view = [arguments lastObject];
        NSString * viewStr = view && [view isKindOfClass:[NSString class]] ? view : @"main";
        [request setMethod:@"d.multicall" withParameters:@[viewStr, @"d.get_hash=", @"d.get_directory=", @"d.get_base_path=", @"d.get_completed_bytes=", @"d.get_size_bytes=", @"d.get_name=", @"d.get_up_rate=", @"d.get_down_rate=", @"d.get_up_total=", @"d.get_down_total=", @"d.get_state="]];
    } else if (type == ANRTorrentOperationListFiles) {
        NSString * fileHash = [[arguments lastObject] uppercaseString];
        NSAssert(fileHash, @"File list command takes exactly one argument");
        // second argument appears to be worthless. gotta love open source software
        [request setMethod:@"f.multicall" withParameters:@[fileHash, @1337, @"f.get_completed_chunks=", @"f.get_frozen_path=", @"f.get_path=", @"f.get_path_components=", @"f.get_priority=", @"f.get_range_first=", @"f.get_range_second=", @"f.get_size_bytes=", @"f.get_size_chunks=", @"f.is_create_queued=", @"f.is_created=", @"f.is_open=", @"f.is_resize_queued="]];
    } else {
        NSArray * names = @[@"d.erase", @"load", @"d.start", @"d.stop", @"d.close", @"f.set_priority"];
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
    } else if (type == ANRTorrentOperationListFiles) {
        NSArray * lists = [[responses lastObject] object];
        NSMutableArray * files = [[NSMutableArray alloc] initWithCapacity:[lists count]];
        for (UInt32 index = 0; index < [lists count]; index++) {
            NSArray * list = [lists objectAtIndex:index];
            ANRTorrentFile * file = [[ANRTorrentFile alloc] initWithArray:list];
            file.fileIndex = index;
            [files addObject:file];
        }
        return files;
    } else {
        return [[responses lastObject] object];
    }
}

@end
