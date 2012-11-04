//
//  ANSettingsController.m
//  iRTorrent
//
//  Created by Alex Nichol on 10/29/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANSettingsController.h"

@implementation ANSettingsController

+ (NSString *)username {
    NSString * username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    if (!username) return @"root";
    return username;
}

+ (NSString *)password {
    NSString * password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    if (!password) return @"";
    return password;
}

+ (NSString *)host {
    NSString * value = [[NSUserDefaults standardUserDefaults] objectForKey:@"server_name"];
    if (!value) return @"107.22.194.29";
    return value;
}

@end
