//
//  ANRTorrentOperation.h
//  iRTorrent
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANRPCCall.h"
#import "ANRTorrentInfo.h"
#import "ANRTorrentFile.h"

typedef enum {
    ANRTorrentOperationErase = 0,
    ANRTorrentOperationLoad,
    ANRTorrentOperationStart,
    ANRTorrentOperationStop,
    ANRTorrentOperationClose,
    ANRTorrentOperationSetPriority,
    ANRTorrentOperationList,
    ANRTorrentOperationListFiles
} ANRTorrentOperationType;

@interface ANRTorrentOperation : NSObject <ANRPCCall> {
    ANRTorrentOperationType type;
    NSArray * arguments;
}

@property (readonly) ANRTorrentOperationType type;
@property (readonly) NSArray * arguments;

- (id)initWithOperation:(ANRTorrentOperationType)operation arguments:(NSArray *)args;

@end
