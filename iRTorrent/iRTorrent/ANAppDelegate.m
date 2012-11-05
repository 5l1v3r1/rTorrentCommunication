//
//  ANAppDelegate.m
//  iRTorrent
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANAppDelegate.h"

#import "ANRootViewController.h"
#import "ANDownloadsViewController.h"

@implementation ANAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ANRootViewController alloc] init];
    self.downloadsViewController = [[ANDownloadsViewController alloc] init];
    
    self.navigationController = [[UINavigationController alloc] init];
    self.navigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Torrents"
                                                                         image:[UIImage imageNamed:@"torrent"]
                                                                           tag:1];
    
    self.downloadsNavigation = [[UINavigationController alloc] init];
    self.downloadsNavigation.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:0];

    self.tabBar = [[UITabBarController alloc] init];
    self.tabBar.viewControllers = @[self.navigationController, self.downloadsNavigation];
    [self.navigationController pushViewController:self.viewController animated:NO];
    [self.downloadsNavigation pushViewController:self.downloadsViewController animated:NO];
    self.window.rootViewController = self.tabBar;
    [self.window makeKeyAndVisible];
    
    self.tabBar.delegate = self;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self.downloadsViewController pauseAllTransfers];
    [self.downloadsViewController saveTransfers];
    [self.viewController.fileVC stopRefreshing];
    [self.viewController severSession];
    [self.viewController invalidateRefreshTimer];
}

//- (void)applicationDidEnterBackground:(UIApplication *)application {
//}
//
//- (void)applicationWillEnterForeground:(UIApplication *)application {
//    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//    BOOL changed = NO;
//    if (![[ANSettingsController host] isEqualToString:self.viewController.session.host]) {
//        changed = YES;
//    }
//    if (![[ANSettingsController username] isEqualToString:self.viewController.session.username]) {
//        changed = YES;
//    }
//    if (![[ANSettingsController password] isEqualToString:self.viewController.session.password]) {
//        changed = YES;
//    }
//    if (changed) {
//        [self.viewController restartSession];
//    }
//}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Check the settings changed
    if (!self.viewController.session) [self.viewController restartSession];
    [self.viewController createRefreshTimer];
    [self.viewController.fileVC startRefreshing];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self.downloadsViewController saveTransfers];
}

#pragma mark Tab Bar

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (viewController != self.navigationController) {
        [self.viewController invalidateRefreshTimer];
        [self.viewController severSession];
    } else {
        if (!self.viewController.session) [self.viewController restartSession];
        [self.viewController createRefreshTimer];
    }
}

@end
