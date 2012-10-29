//
//  ANAppDelegate.h
//  iRTorrent
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ANRootViewController;

@interface ANAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow * window;
@property (strong, nonatomic) UINavigationController * navigationController;
@property (strong, nonatomic) ANRootViewController * viewController;

@end
