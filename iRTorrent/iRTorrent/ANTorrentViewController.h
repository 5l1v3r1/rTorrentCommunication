//
//  ANTorrentViewController.h
//  iRTorrent
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ANRTorrentInfo.h"

@class ANTorrentViewController;

@protocol ANTorrentViewControllerDelegate

- (void)torrentViewControllerStartRequested:(ANTorrentViewController *)tvc;
- (void)torrentViewControllerStopRequested:(ANTorrentViewController *)tvc;

@end

@interface ANTorrentViewController : UITableViewController {
    __weak id<ANTorrentViewControllerDelegate> delegate;
    ANRTorrentInfo * torrentInfo;
    
    UILabel * torrentName;
    UIBarButtonItem * startButton;
    UIBarButtonItem * stopButton;
}

@property (nonatomic, readonly) ANRTorrentInfo * torrentInfo;
@property (nonatomic, weak) id<ANTorrentViewControllerDelegate> delegate;

- (id)initWithTorrentInfo:(ANRTorrentInfo *)info;
- (void)updateWithTorrentInfo:(ANRTorrentInfo *)newInfo;

- (void)startPressed:(id)sender;
- (void)stopPressed:(id)sender;

@end
