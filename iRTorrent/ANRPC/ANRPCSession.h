//
//  ANRPCSession.h
//  RTorrentControl
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANRPCCall.h"
#import "ANRPCConnection.h"

@class ANRPCSession;

@protocol ANRPCSessionDelegate <NSObject>

@optional
- (void)rpcSession:(ANRPCSession *)session call:(id<ANRPCCall>)call gotResponse:(id)response;
- (void)rpcSession:(ANRPCSession *)session call:(id<ANRPCCall>)call failedWithError:(NSError *)error;

@end

@interface ANRPCSession : NSObject {
    NSString * host;
    UInt16 port;
    NSString * username;
    NSString * password;
    __weak id<ANRPCSessionDelegate> delegate;
    
    NSThread * backgroundThread;
    dispatch_queue_t mainQueue;
    ANRPCConnection * connection;
}

@property (nonatomic, weak) id<ANRPCSessionDelegate> delegate;

- (id)initWithHost:(NSString *)aHost port:(UInt16)aPort username:(NSString *)aUsername password:(NSString *)aPassword;
- (void)pushCall:(id<ANRPCCall>)call;
- (void)cancelAll;

@end
