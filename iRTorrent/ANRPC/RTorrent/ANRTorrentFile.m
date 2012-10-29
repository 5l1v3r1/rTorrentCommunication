//
//  ANRTorrentFile.m
//  iRTorrent
//
//  Created by Alex Nichol on 10/29/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANRTorrentFile.h"

@implementation ANRTorrentFile

@synthesize completedChunks;
@synthesize frozenPath;
@synthesize path;
@synthesize pathComponents;
@synthesize priority;
@synthesize torrentRange;
@synthesize sizeBytes;
@synthesize sizeChunks;
@synthesize isCreateQueued;
@synthesize isCreated;
@synthesize isOpen;
@synthesize isResizeQueued;
@synthesize fileIndex;

- (id)initWithArray:(NSArray *)array {
    if ((self = [super init])) {
        completedChunks = [[array objectAtIndex:0] longLongValue];
        frozenPath = [array objectAtIndex:1];
        path = [array objectAtIndex:2];
        pathComponents = [array objectAtIndex:3];
        priority = (SInt32)[[array objectAtIndex:4] intValue];
        torrentRange.location = [[array objectAtIndex:5] longLongValue];
        torrentRange.length = [[array objectAtIndex:6] longLongValue] - torrentRange.location;
        sizeBytes = [[array objectAtIndex:7] longLongValue];
        sizeChunks = [[array objectAtIndex:8] longLongValue];
        isCreateQueued = (BOOL)[[array objectAtIndex:9] intValue];
        isCreated = (BOOL)[[array objectAtIndex:10] intValue];
        isOpen = (BOOL)[[array objectAtIndex:11] intValue];
        isResizeQueued = (BOOL)[[array objectAtIndex:12] intValue];
    }
    return self;
}

@end
