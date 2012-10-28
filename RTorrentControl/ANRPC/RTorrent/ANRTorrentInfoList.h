//
//  ANRTorrentInfo.h
//  RTorrentControl
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANRTorrentInfo.h"
#import "ANRPCCall.h"

@interface ANRTorrentInfoList : NSObject <ANRPCCall> {
    NSString * view;
}

- (id)initWithView:(NSString *)aView;

@end
