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
#import "NSNumber+FileSize.h"
#import "ANSettingsController.h"
#import "ANTorrentFileViewController.h"

@interface ANRootViewController : UITableViewController <ANRPCSessionDelegate, ANTorrentViewControllerDelegate, ANAddViewControllerDelegate> {
    ANRPCSession * session;
    NSArray * torrentList;
    NSTimer * refreshTimer;
    BOOL hasRefreshed;
    BOOL hasAlerted;
    
    UIBarButtonItem * addButton;
    ANTorrentViewController * activeTorrentVC;
    
    __weak ANTorrentFileViewController * fileVC;
}

@property (readonly) ANRPCSession * session;
@property (readonly) ANTorrentFileViewController * fileVC;

- (void)severSession;
- (void)restartSession;
- (void)createRefreshTimer;
- (void)invalidateRefreshTimer;

- (void)addPressed:(id)sender;
- (void)refreshItems:(id)sender;
- (void)fileViewSetPriority:(NSNotification *)notification;
- (void)fileViewDownloadTapped:(NSNotification *)notification;
- (void)fileViewAppeared:(NSNotification *)notification;
- (void)fileViewDisappeared:(NSNotification *)notification;
- (void)fileViewRefreshRequest:(NSNotification *)notification;

- (void)intelligentlyReloadTable:(NSArray *)newList;

@end
