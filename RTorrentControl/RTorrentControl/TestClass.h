//
//  TestClass.h
//  RTorrentControl
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANRPCSession.h"
#import "ANRTorrentInfoList.h"
#import "ANRTorrentLoad.h"

@interface TestClass : NSObject <ANRPCSessionDelegate> {
    ANRPCSession * theSession;
}

- (void)start;

@end
