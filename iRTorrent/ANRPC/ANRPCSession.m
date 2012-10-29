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
- (NSData *)attemptExecution:(NSData *)request error:(NSError **)error;

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
        [connection disconnect];
        connection = nil;
    }
}

- (void)runCall:(id<ANRPCCall>)call {
    NSArray * requests = [call encodeRequests];
    NSMutableArray * responses = [NSMutableArray array];
    for (XMLRPCRequest * request in requests) {
        NSData * data = [[request body] dataUsingEncoding:NSUTF8StringEncoding];
        NSError * error = nil;
        NSData * response = nil;
        // if we are not connected, try to connect; otherwise, try on the existing
        // connection, and if this fails then create a new connection.
        if (!connection) {
            response = [self attemptExecution:data error:&error];
        } else {
            response = [self attemptExecution:data error:&error];
            if (!response) {
                [connection disconnect];
                connection = nil;
                response = [self attemptExecution:data error:&error];
            }
        }
        XMLRPCResponse * resp = [[XMLRPCResponse alloc] initWithData:response];
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

- (NSData *)attemptExecution:(NSData *)request error:(NSError **)error {
    if (!connection) {
        connection = [[ANRPCConnection alloc] initWithHost:host
                                                      port:port
                                                  username:username
                                                  password:password];
        if (![connection connect:error]) {
            connection = nil;
        }
    }
    NSData * result = connection ? [connection sendSynchronousRequest:request error:error] : nil;
    return result;
}

@end
