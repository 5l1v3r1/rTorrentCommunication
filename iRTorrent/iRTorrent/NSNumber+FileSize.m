//
//  NSNumber+FileSize.m
//  iRTorrent
//
//  Created by Alex Nichol on 10/29/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "NSNumber+FileSize.h"

@implementation NSNumber (FileSize)

- (NSString *)fileSizeString {
    if ([self doubleValue] == 0) return @"0 Bytes";
    NSArray * units = @[@"Bytes", @"KB", @"MB", @"GB", @"TB"];
    int power = (int)floor(log([self doubleValue]) / log(1024));
    if (power >= [units count]) power = [units count] - 1;
    float value = [self doubleValue] / pow(1024, power);
    return [NSString stringWithFormat:@"%.2f %@", value, [units objectAtIndex:power]];
}

NSString * filesizeStringForSize(unsigned long long size) {
    return [[NSNumber numberWithLongLong:size] fileSizeString];
}

@end
