//
//  ANTorrentDirViewController.h
//  iRTorrent
//
//  Created by Alex Nichol on 10/29/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANRTorrentDirectory.h"
#import "ANTorrentFileViewController.h"

@interface ANTorrentDirViewController : UITableViewController {
    ANRTorrentDirectory * directory;
}

- (id)initWithDirectory:(ANRTorrentDirectory *)aDirectory;

@end
