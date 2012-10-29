//
//  ANRTorrentDirectory.h
//  iRTorrent
//
//  Created by Alex Nichol on 10/29/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANRTorrentFile.h"

@interface ANRTorrentDirectory : NSObject {
    NSString * directoryName;
    NSMutableArray * items;
}

@property (readonly) NSString * directoryName;
@property (readonly) NSArray * items;

- (id)initRootWithFiles:(NSArray *)files;
- (id)initWithName:(NSString *)name;
- (void)addItem:(id)item;

@end
