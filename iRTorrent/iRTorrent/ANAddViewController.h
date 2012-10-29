//
//  ANAddViewController.h
//  iRTorrent
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ANAddViewController;

@protocol ANAddViewControllerDelegate

- (void)addViewController:(ANAddViewController *)addVc addedURL:(NSString *)str;

@end

@interface ANAddViewController : UIViewController {
    UITextField * urlField;
    __weak id<ANAddViewControllerDelegate> delegate;
}

@property (nonatomic, weak) id<ANAddViewControllerDelegate> delegate;

- (void)donePressed:(id)sender;

@end
