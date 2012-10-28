//
//  ANRTorrentStop.h
//  RTorrentControl
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANRPCCall.h"

@interface ANRTorrentStop : NSObject <ANRPCCall> {
    NSString * hash;
}

@property (readonly) NSString * hash;

- (id)initWithHash:(NSString *)aHash;

@end
