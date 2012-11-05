//
//  ANTorrentFileViewController.h
//  iRTorrent
//
//  Created by Alex Nichol on 10/29/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ANRTorrentFile.h"
#import "ANLabelHeader.h"
#import "NSNumber+FileSize.h"

#define ANTorrentFileViewControllerChangedPriorityNotification @"ANTorrentFileViewControllerChangedPriorityNotification"
#define ANTorrentFileViewControllerDownloadTappedNotification @"ANTorrentFileViewControllerDownloadTappedNotification"
#define ANTorrentFileViewRequestInfoNotification @"ANTorrentFileViewRequestInfoNotification"
#define ANTorrentFileViewDidAppearNotification @"ANTorrnetFileViewDidAppearNotification"
#define ANTorrentFileViewDidDisappearNotification @"ANTorrentFileViewDidDisappearNotification"

@interface ANTorrentFileViewController : UITableViewController {
    UISegmentedControl * prioritySegment;
    ANRTorrentFile * torrentFile;
    UIBarButtonItem * downloadButton;
    
    NSTimer * refreshTimer;
    BOOL hasRefreshed;
    BOOL hasShownError;
}

@property (readonly) ANRTorrentFile * torrentFile;

- (id)initWithFile:(ANRTorrentFile *)file;
- (void)segmentChanged:(id)sender;
- (void)downloadPressed:(id)sender;

- (void)stopRefreshing;
- (void)startRefreshing;
- (void)refreshTimerTick:(id)sender;
- (void)refreshFileInfoFailed:(NSError *)error;
- (void)refreshFileInfoSucceeded:(ANRTorrentFile *)nowInfo;

@end
