//
//  ANTransfer.m
//  iRTorrent
//
//  Created by Alex Nichol on 10/29/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANTransfer.h"

@interface ANTransfer (Private)

- (void)setState:(ANTransferState)aState;
- (void)transferMain;
- (void)callbackError:(NSString *)error code:(int)code;
- (void)callbackTrueError:(NSError *)error;

@end

@implementation ANTransfer

@synthesize delegate;
@synthesize localPath;
@synthesize remotePath;
@synthesize host;
@synthesize port;
@synthesize username;
@synthesize password;
@synthesize totalSize;
@synthesize hasSize;

- (ANTransferState)state {
    ANTransferState s;
    [stateLock lock];
    s = state;
    [stateLock unlock];
    return s;
}

- (id)initWithLocalFile:(NSString *)local remoteFile:(NSString *)remote {
    if ((self = [super init])) {
        localPath = local;
        remotePath = remote;
    }
    return self;
}

- (void)startTransfer {
    if (backgroundThread) return;
    [self setState:ANTransferStateEstablishing];
    backgroundThread = [[NSThread alloc] initWithTarget:self
                                               selector:@selector(transferMain)
                                                 object:nil];
    [backgroundThread start];
}

- (void)cancelTransfer {
    if (!backgroundThread) return;
    [backgroundThread cancel];
    backgroundThread = nil;
    [self setState:ANTransferStateNotRunning];
}

#pragma mark - Private -

- (void)setState:(ANTransferState)aState {
    if ([[NSThread currentThread] isCancelled]) return;
    [stateLock lock];
    state = aState;
    [stateLock unlock];
}

#pragma mark Background Thread

- (void)transferMain {
    @autoreleasepool {
        if (![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
            [[NSFileManager defaultManager] createFileAtPath:localPath contents:[NSData data] attributes:nil];
        }
        NSFileHandle * handle = [NSFileHandle fileHandleForUpdatingAtPath:localPath];
        if (!handle) {
            [self setState:ANTransferStateNotRunning];
            [self callbackError:@"Failed to open local file" code:1];
            return;
        }
        transfer = [[ANSynchronousTransfer alloc] initWithHost:host port:port];
        if (![transfer connect]) {
            [transfer close];
            [handle closeFile];
            transfer = nil;
            [self setState:ANTransferStateNotRunning];
            [self callbackError:@"Failed to connect to remote host" code:2];
            return;
        }
        [handle seekToEndOfFile];
        long long offset = (long long)[handle offsetInFile];
        if (![transfer sendUsername:username password:password path:remotePath initial:offset]) {
            [handle closeFile];
            [transfer close];
            transfer = nil;
            [self callbackError:@"Failed to send headers" code:3];
            [self setState:ANTransferStateNotRunning];
            return;
        }
        [self setState:ANTransferStateEstablishing];
        NSError * error = nil;
        NSNumber * readLength = [transfer readResponse:&error];
        if (!readLength) {
            [handle closeFile];
            [transfer close];
            transfer = nil;
            [self setState:ANTransferStateNotRunning];
            [self callbackTrueError:error];
            return;
        }
        [self setState:ANTransferStateTransferring];
        totalSize = [readLength longLongValue] + offset;
        long long remaining = [readLength longLongValue];
        int lastUpdate = 0;
        while (remaining > 0) {
            if ([[NSThread currentThread] isCancelled]) break;
            NSNumber * bytes = [transfer readBlockToFile:handle];
            if (!bytes) {
                [handle closeFile];
                [transfer close];
                transfer = nil;
                [self setState:ANTransferStateNotRunning];
                [self callbackError:@"Failed to read from socket" code:EREMOTE];
                return;
            }
            if ([[NSThread currentThread] isCancelled]) break;
            remaining -= [bytes longLongValue];
            lastUpdate += [bytes intValue];
            hasSize = (long long)[handle offsetInFile];
            if (lastUpdate >= 65536) {
                lastUpdate = 0;
                float progress = 1.0 - ((float)remaining / (float)totalSize);
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if ([delegate respondsToSelector:@selector(transfer:progressChanged:)]) {
                        [delegate transfer:self progressChanged:progress];
                    }
                });
            }
        }
        [handle closeFile];
        [transfer close];
        transfer = nil;
        if ([[NSThread currentThread] isCancelled]) return;
        [self setState:ANTransferStateNotRunning];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(transferCompleted:)]) {
                [delegate transferCompleted:self];
            }
        });
        backgroundThread = nil;
    }
}

- (void)callbackError:(NSString *)error code:(int)code {
    NSError * err = [NSError errorWithDomain:@"ANTransfer"
                                        code:code
                                    userInfo:@{NSLocalizedDescriptionKey: error}];
    [self callbackTrueError:err];
}

- (void)callbackTrueError:(NSError *)error {
    if ([[NSThread currentThread] isCancelled]) return;
    dispatch_sync(dispatch_get_main_queue(), ^{
        if ([delegate respondsToSelector:@selector(transfer:failedWithError:)]) {
            [delegate transfer:self failedWithError:error];
        }
    });
}

@end
