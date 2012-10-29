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
#import "ANTorrentDirViewController.h"
#import "ANLabelHeader.h"
#import "NSNumber+FileSize.h"

@class ANTorrentViewController;

@protocol ANTorrentViewControllerDelegate

- (void)torrentViewControllerStartRequested:(ANTorrentViewController *)tvc;
- (void)torrentViewControllerStopRequested:(ANTorrentViewController *)tvc;

@end

@interface ANTorrentViewController : UITableViewController {
    __weak id<ANTorrentViewControllerDelegate> delegate;
    ANRTorrentInfo * torrentInfo;
    
    UIBarButtonItem * startButton;
    UIBarButtonItem * stopButton;
    
    ANRTorrentDirectory * rootDirectory;
}

@property (nonatomic, readonly) ANRTorrentInfo * torrentInfo;
@property (nonatomic, weak) id<ANTorrentViewControllerDelegate> delegate;

- (id)initWithTorrentInfo:(ANRTorrentInfo *)info;
- (void)updateWithTorrentInfo:(ANRTorrentInfo *)newInfo;
- (void)fetchedTorrentRoot:(ANRTorrentDirectory *)root;

- (void)startPressed:(id)sender;
- (void)stopPressed:(id)sender;

@end
