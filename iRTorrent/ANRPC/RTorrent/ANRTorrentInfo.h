//
//  ANRTorrentInfo.h
//  RTorrentControl
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANRTorrentInfo : NSObject {
    NSString * torrentHash;
    NSString * baseDirectory;
    NSString * baseFile;
    UInt64 bytesDone;
    UInt64 totalBytes;
    NSString * name;
    float uploadRate;
    float downRate;
    float uploadTotal;
    float downloadTotal;
    NSString * state;
}

@property (nonatomic, strong) NSString * torrentHash;
@property (nonatomic, strong) NSString * baseDirectory;
@property (nonatomic, strong) NSString * baseFile;
@property (readwrite) UInt64 bytesDone;
@property (readwrite) UInt64 totalBytes;
@property (nonatomic, strong) NSString * name;
@property (readwrite) float uploadRate;
@property (readwrite) float downRate;
@property (readwrite) float uploadTotal;
@property (readwrite) float downloadTotal;
@property (nonatomic, strong) NSString * state;

- (id)initWithArray:(NSArray *)fields;
- (BOOL)isEqualToInfo:(ANRTorrentInfo *)info;

@end
