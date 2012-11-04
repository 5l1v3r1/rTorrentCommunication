//
//  ANAppDelegate.h
//  iRTorrent
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANSettingsController.h"

@class ANRootViewController;
@class ANDownloadsViewController;

@interface ANAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow * window;
@property (strong, nonatomic) UINavigationController * navigationController;
@property (strong, nonatomic) ANRootViewController * viewController;
@property (strong, nonatomic) UINavigationController * downloadsNavigation;
@property (strong, nonatomic) ANDownloadsViewController * downloadsViewController;
@property (strong, nonatomic) UITabBarController * tabBar;

@end
