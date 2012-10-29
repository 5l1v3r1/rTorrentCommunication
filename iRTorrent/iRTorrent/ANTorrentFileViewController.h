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

@interface ANTorrentFileViewController : UITableViewController {
    UISegmentedControl * prioritySegment;
    ANRTorrentFile * torrentFile;
}

@property (readonly) ANRTorrentFile * torrentFile;

- (id)initWithFile:(ANRTorrentFile *)file;
- (void)segmentChanged:(id)sender;

@end
