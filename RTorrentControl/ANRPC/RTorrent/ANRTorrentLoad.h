//
//  ANRTorrentLoad.h
//  RTorrentControl
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANRPCCall.h"

@interface ANRTorrentLoad : NSObject <ANRPCCall> {
    NSURL * torrentURL;
}

@property (readonly) NSURL * torrentURL;

- (id)initWithURL:(NSURL *)url;

@end
