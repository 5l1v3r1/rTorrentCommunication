//
//  NSNumber+FileSize.h
//  iRTorrent
//
//  Created by Alex Nichol on 10/29/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString * filesizeStringForSize(unsigned long long size);

@interface NSNumber (FileSize)

- (NSString *)fileSizeString;

@end
