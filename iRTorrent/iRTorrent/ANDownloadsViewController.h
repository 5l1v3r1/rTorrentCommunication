//
//  ANDownloadsViewController.h
//  iRTorrent
//
//  Created by Alex Nichol on 10/29/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANTransfer.h"
#import "ANTransferCell.h"
#import "ANSettingsController.h"
#import "ANFileViewController.h"

@interface ANDownloadsViewController : UITableViewController <ANTransferDelegate> {
    NSMutableArray * transfers;
}

- (void)addTransfer:(ANTransfer *)aTransfer;
- (void)downloadCellPlayPause:(NSNotification *)notification;
- (void)saveTransfers;

@end
