//
//  ANTransfer.h
//  iRTorrent
//
//  Created by Alex Nichol on 10/29/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANSynchronousTransfer.h"

typedef enum {
    ANTransferStateNotRunning,
    ANTransferStateEstablishing,
    ANTransferStateTransferring
} ANTransferState;

@class ANTransfer;

@protocol ANTransferDelegate <NSObject>

@optional
- (void)transfer:(ANTransfer *)transfer failedWithError:(NSError *)error;
- (void)transfer:(ANTransfer *)transfer progressChanged:(float)progress;
- (void)transferCompleted:(ANTransfer *)transfer;

@end

@interface ANTransfer : NSObject <NSCoding> {
    NSLock * stateLock;
    ANTransferState state;
    
    ANSynchronousTransfer * transfer;
    NSFileHandle * handle;
    NSThread * backgroundThread;
    
    NSString * localPath;
    NSString * remotePath;
    NSString * host;
    UInt16 port;
    NSString * username;
    NSString * password;
    
    long long totalSize;
    long long hasSize;
    
    __weak id<ANTransferDelegate> delegate;
}

@property (readonly) ANTransferState state;
@property (readonly) NSString * remotePath;
@property (readonly) NSString * localPath;
@property (nonatomic, weak) id<ANTransferDelegate> delegate;
@property (nonatomic, strong) NSString * host;
@property (readwrite) UInt16 port;
@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSString * password;
@property (readonly) long long totalSize;
@property (readonly) long long hasSize;

- (id)initWithLocalFile:(NSString *)local remoteFile:(NSString *)remote totalSize:(long long)estimate;
- (void)startTransfer;
- (void)cancelTransfer;

@end
