//
//  ANRTorrentDirectory.m
//  iRTorrent
//
//  Created by Alex Nichol on 10/29/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANRTorrentDirectory.h"

@implementation ANRTorrentDirectory

@synthesize directoryName;
@synthesize items;

- (id)initRootWithFiles:(NSArray *)files {
    if ((self = [super init])) {
        directoryName = @"/";
        items = [[NSMutableArray alloc] init];
        for (ANRTorrentFile * file in files) {
            ANRTorrentDirectory * directory = self;
            for (int i = 0; i < (int)[[file pathComponents] count] - 1; i++) {
                NSString * name = [[file pathComponents] objectAtIndex:i];
                // search for directory name
                BOOL found = NO;
                for (id item in directory.items) {
                    if (![item isKindOfClass:[ANRTorrentDirectory class]]) continue;
                    if ([[item directoryName] isEqualToString:name]) {
                        directory = item;
                        found = YES;
                        break;
                    }
                }
                if (!found) {
                    ANRTorrentDirectory * newDir = [[ANRTorrentDirectory alloc] initWithName:name];
                    [directory addItem:newDir];
                    directory = newDir;
                }
            }
            [directory addItem:file];
        }
    }
    return self;
}

- (id)initWithName:(NSString *)name {
    if ((self = [super init])) {
        directoryName = name;
        items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addItem:(id)item {
    [items addObject:item];
}

@end
