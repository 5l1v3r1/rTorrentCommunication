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

@interface ANRootViewController : UITableViewController <ANRPCSessionDelegate> {
    ANRPCSession * session;
    NSArray * torrentList;
}

@end
