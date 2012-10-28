//
//  ANRPCCall.h
//  RTorrentControl
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLRPCRequest.h"
#import "XMLRPCResponse.h"

@protocol ANRPCCall <NSObject>

- (NSArray *)encodeRequests;
- (id)responseObject:(NSArray *)responses;

@end
