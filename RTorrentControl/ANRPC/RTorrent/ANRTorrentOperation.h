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

typedef enum {
    ANRTorrentOperationErase = 0,
    ANRTorrentOperationLoad,
    ANRTorrentOperationStart,
    ANRTorrentOperationStop,
    ANRTorrentOperationList
} ANRTorrentOperationType;

@interface ANRTorrentOperation : NSObject <ANRPCCall> {
    ANRTorrentOperationType type;
    NSArray * arguments;
}

- (id)initWithOperation:(ANRTorrentOperationType)operation arguments:(NSArray *)args;

@end