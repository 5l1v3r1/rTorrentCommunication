//
//  ANRTorrentInfo.m
//  RTorrentControl
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANRTorrentInfo.h"

@implementation ANRTorrentInfo

@synthesize torrentHash;
@synthesize baseDirectory;
@synthesize baseFile;
@synthesize bytesDone;
@synthesize totalBytes;
@synthesize name;
@synthesize uploadRate;
@synthesize downRate;
@synthesize uploadTotal;
@synthesize downloadTotal;
@synthesize state;

- (id)initWithArray:(NSArray *)fields {
    if ((self = [super init])) {
        torrentHash = [fields objectAtIndex:0];
        baseDirectory = [fields objectAtIndex:1];
        baseFile = [fields objectAtIndex:2];
        bytesDone = [[fields objectAtIndex:3] longLongValue];
        totalBytes = [[fields objectAtIndex:4] longLongValue];
        name = [fields objectAtIndex:5];
        uploadRate = [[fields objectAtIndex:6] floatValue];
        downRate = [[fields objectAtIndex:7] floatValue];
        uploadTotal = [[fields objectAtIndex:8] floatValue];
        downloadTotal = [[fields objectAtIndex:9] floatValue];
        state = [fields objectAtIndex:10];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<ANRTorrentInfo: %@ - (%lu of %lu) - %@>", name, (unsigned long)bytesDone, (unsigned long)totalBytes, state];
}

@end
