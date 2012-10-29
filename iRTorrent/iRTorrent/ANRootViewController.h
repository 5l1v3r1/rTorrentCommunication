//
//  ANViewController.h
//  iRTorrent
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANRPCSession.h"
#import "ANRTorrentOperation.h"
#import "ANTorrentCell.h"
#import "ANTorrentViewController.h"
#import "ANAddViewController.h"

@interface ANRootViewController : UITableViewController <ANRPCSessionDelegate, ANTorrentViewControllerDelegate, ANAddViewControllerDelegate> {
    ANRPCSession * session;
    NSArray * torrentList;
    NSTimer * refreshTimer;
    BOOL hasRefreshed;
    BOOL hasAlerted;
    
    UIBarButtonItem * addButton;
    ANTorrentViewController * activeTorrentVC;
}

- (void)addPressed:(id)sender;
- (void)refreshItems:(id)sender;

- (void)intelligentlyReloadTable:(NSArray *)newList;

@end
