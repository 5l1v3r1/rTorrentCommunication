//
//  ANRPCSession.m
//  RTorrentControl
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANRPCSession.h"

@interface ANRPCSession (Private)

- (void)backgroundThread;
- (void)runCall:(id)sender;

@end

@implementation ANRPCSession

@synthesize delegate;

- (id)initWithHost:(NSString *)aHost port:(UInt16)aPort username:(NSString *)aUsername password:(NSString *)aPassword {
    if ((self = [super init])) {
        host = aHost;
        port = aPort;
        username = aUsername;
        password = aPassword;
        mainQueue = dispatch_get_main_queue();
        backgroundThread = [[NSThread alloc] initWithTarget:self selector:@selector(backgroundThread) object:nil];
        [backgroundThread start];
    }
    return self;
}

- (void)pushCall:(id<ANRPCCall>)call {
    [self performSelector:@selector(runCall:) onThread:backgroundThread withObject:call waitUntilDone:NO];
}

- (void)cancelAll {
    [backgroundThread cancel];
    backgroundThread = nil;
}

#pragma mark - Private -

- (void)backgroundThread {
    @autoreleasepool {
        while (![[NSThread currentThread] isCancelled]) {
            [[NSRunLoop currentRunLoop] run];
            [NSThread sleepForTimeInterval:0.1];
        }
    }
}

- (void)runCall:(id<ANRPCCall>)call {
    NSArray * requests = [call encodeRequests];
    NSMutableArray * responses = [NSMutableArray array];
    for (XMLRPCRequest * request in requests) {
        NSData * data = [[request body] dataUsingEncoding:NSUTF8StringEncoding];
        ANRPCConnection * conn = [[ANRPCConnection alloc] initWithHost:host
                                                                  port:port
                                                              username:username
                                                              password:password
                                                               request:data];
        NSError * error = nil;
        NSData * result = [conn callSynchronously:&error];
        if (error || !result) {
            dispatch_sync(mainQueue, ^{
                if ([delegate respondsToSelector:@selector(rpcSession:call:failedWithError:)]) {
                    [delegate rpcSession:self call:call failedWithError:error];
                }
            });
            return;
        }
        XMLRPCResponse * resp = [[XMLRPCResponse alloc] initWithData:result];
        if (!resp) {
            NSError * err = [NSError errorWithDomain:@"ANRPCSession" code:1
                                            userInfo:@{NSLocalizedDescriptionKey: @"Invalid response"}];
            dispatch_sync(mainQueue, ^{
                if ([delegate respondsToSelector:@selector(rpcSession:call:failedWithError:)]) {
                    [delegate rpcSession:self call:call failedWithError:err];
                }
            });
            return;
        }
        [responses addObject:resp];
    }
    id object = [call responseObject:responses];
    dispatch_sync(mainQueue, ^{
        if ([delegate respondsToSelector:@selector(rpcSession:call:gotResponse:)]) {
            [delegate rpcSession:self call:call gotResponse:object];
        }
    });
}

@end
