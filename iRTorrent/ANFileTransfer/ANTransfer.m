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
- (void)cleanupAll;

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

- (id)initWithLocalFile:(NSString *)local remoteFile:(NSString *)remote totalSize:(long long)estimate {
    if ((self = [super init])) {
        localPath = local;
        remotePath = remote;
        totalSize = estimate;
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

#pragma mark - Coding -

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:host forKey:@"host"];
    [aCoder encodeObject:username forKey:@"username"];
    [aCoder encodeObject:password forKey:@"password"];
    [aCoder encodeInt32:port forKey:@"port"];
    [aCoder encodeObject:remotePath forKey:@"remote"];
    [aCoder encodeObject:localPath forKey:@"local"];
    [aCoder encodeInt64:totalSize forKey:@"total"];
    [aCoder encodeInt64:hasSize forKey:@"has"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        host = [aDecoder decodeObjectForKey:@"host"];
        username = [aDecoder decodeObjectForKey:@"username"];
        password = [aDecoder decodeObjectForKey:@"password"];
        port = [aDecoder decodeInt32ForKey:@"port"];
        remotePath = [aDecoder decodeObjectForKey:@"remote"];
        localPath = [aDecoder decodeObjectForKey:@"local"];
        totalSize = [aDecoder decodeInt64ForKey:@"total"];
        hasSize = [aDecoder decodeInt64ForKey:@"has"];
    }
    return self;
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
        handle = [NSFileHandle fileHandleForUpdatingAtPath:localPath];
        if (!handle) {
            [self setState:ANTransferStateNotRunning];
            [self callbackError:@"Failed to open local file" code:1];
            return;
        }
        transfer = [[ANSynchronousTransfer alloc] initWithHost:host port:port];
        if (![transfer connect]) {
            [self cleanupAll];
            [self callbackError:@"Failed to connect to remote host" code:2];
            return;
        }
        [handle seekToEndOfFile];
        long long offset = (long long)[handle offsetInFile];
        if (![transfer sendUsername:username password:password path:remotePath initial:offset]) {
            [self cleanupAll];
            [self callbackError:@"Failed to send headers" code:3];
            return;
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            hasSize = offset;
        });
        [self setState:ANTransferStateEstablishing];
        NSError * error = nil;
        NSNumber * readLength = [transfer readResponse:&error];
        if (!readLength) {
            [self cleanupAll];
            [self callbackTrueError:error];
            return;
        }
        [self setState:ANTransferStateTransferring];
        dispatch_sync(dispatch_get_main_queue(), ^{
            totalSize = [readLength longLongValue] + offset;
        });
        long long remaining = [readLength longLongValue];
        int lastUpdate = 0;
        while (remaining > 0) {
            if ([[NSThread currentThread] isCancelled]) break;
            NSNumber * bytes = [transfer readBlockToFile:handle];
            if (!bytes) {
                [self cleanupAll];
                [self callbackError:@"Failed to read from socket" code:EREMOTE];
                return;
            }
            if ([[NSThread currentThread] isCancelled]) break;
            remaining -= [bytes longLongValue];
            lastUpdate += [bytes intValue];
            dispatch_sync(dispatch_get_main_queue(), ^{
                hasSize = (long long)[handle offsetInFile];
            });
            if (lastUpdate >= 4096) {
                lastUpdate = 0;
                float progress = 1.0 - ((float)remaining / (float)totalSize);
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if ([delegate respondsToSelector:@selector(transfer:progressChanged:)]) {
                        [delegate transfer:self progressChanged:progress];
                    }
                });
            }
        }
        [self cleanupAll];
        if ([[NSThread currentThread] isCancelled]) return;
        backgroundThread = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(transferCompleted:)]) {
                [delegate transferCompleted:self];
            }
        });
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
    backgroundThread = nil;
    dispatch_sync(dispatch_get_main_queue(), ^{
        if ([delegate respondsToSelector:@selector(transfer:failedWithError:)]) {
            [delegate transfer:self failedWithError:error];
        }
    });
}

- (void)cleanupAll {
    [handle closeFile];
    handle = nil;
    [transfer close];
    transfer = nil;
    [self setState:ANTransferStateNotRunning];
}

@end
