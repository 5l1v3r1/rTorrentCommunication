//
//  ANRTorrentFile.h
//  iRTorrent
//
//  Created by Alex Nichol on 10/29/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANRTorrentFile : NSObject {
    UInt64 completedChunks;
    NSString * frozenPath;
    NSString * path;
    NSArray * pathComponents;
    SInt8 priority;
    NSRange torrentRange;
    UInt64 sizeBytes;
    UInt64 sizeChunks;
    BOOL isCreateQueued;
    BOOL isCreated;
    BOOL isOpen;
    BOOL isResizeQueued;
    UInt32 fileIndex;
}

@property (readwrite) UInt64 completedChunks;
@property (nonatomic, strong) NSString * frozenPath;
@property (nonatomic, strong) NSString * path;
@property (nonatomic, strong) NSArray * pathComponents;
@property (readwrite) SInt8 priority;
@property (readwrite) NSRange torrentRange;
@property (readwrite) UInt64 sizeBytes;
@property (readwrite) UInt64 sizeChunks;
@property (readwrite) BOOL isCreateQueued;
@property (readwrite) BOOL isCreated;
@property (readwrite) BOOL isOpen;
@property (readwrite) BOOL isResizeQueued;
@property (readwrite) UInt32 fileIndex;

- (id)initWithArray:(NSArray *)array;

@end
