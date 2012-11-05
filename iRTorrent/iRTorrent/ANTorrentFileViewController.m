//
//  ANTorrentFileViewController.m
//  iRTorrent
//
//  Created by Alex Nichol on 10/29/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANTorrentFileViewController.h"

@interface ANTorrentFileViewController ()

@end

@implementation ANTorrentFileViewController

@synthesize torrentFile;

- (id)initWithFile:(ANRTorrentFile *)file {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        self.title = @"File";
        torrentFile = file;
        prioritySegment = [[UISegmentedControl alloc] initWithItems:@[@"Off", @"Normal", @"High"]];
        prioritySegment.selectedSegmentIndex = file.priority;
        [prioritySegment addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
        
        ANLabelHeader * header = [[ANLabelHeader alloc] initWithWidth:self.view.frame.size.width
                                                                 text:[file.pathComponents lastObject]
                                                                 font:[UIFont boldSystemFontOfSize:16]];
        self.tableView.tableHeaderView = header;
        
        downloadButton = [[UIBarButtonItem alloc] initWithTitle:@"Download"
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(downloadPressed:)];
        self.navigationItem.rightBarButtonItem = downloadButton;
        
        [self startRefreshing];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)segmentChanged:(id)sender {
    torrentFile.priority = (SInt8)prioritySegment.selectedSegmentIndex;
    [[NSNotificationCenter defaultCenter] postNotificationName:ANTorrentFileViewControllerChangedPriorityNotification
                                                        object:self];
}

- (void)downloadPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:ANTorrentFileViewControllerDownloadTappedNotification
                                                        object:self];
}

#pragma mark - Live Updating -

- (void)stopRefreshing {
    [refreshTimer invalidate];
    refreshTimer = nil;
}

- (void)startRefreshing {
    hasRefreshed = YES;
    hasShownError = NO;
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self
                                                  selector:@selector(refreshTimerTick:)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (void)refreshTimerTick:(id)sender {
    if (!hasRefreshed) return;
    hasRefreshed = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:ANTorrentFileViewRequestInfoNotification
                                                        object:self];
}

- (void)refreshFileInfoFailed:(NSError *)error {
    hasRefreshed = YES;
    if (hasShownError) return;
    hasShownError = YES;
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                  message:[error localizedDescription]
                                                 delegate:nil
                                        cancelButtonTitle:nil
                                        otherButtonTitles:@"OK", nil];
    [av show];
}

- (void)refreshFileInfoSucceeded:(ANRTorrentFile *)nowInfo {
    hasShownError = NO;
    torrentFile = nowInfo;
    prioritySegment.selectedSegmentIndex = torrentFile.priority;
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:ANTorrentFileViewDidAppearNotification
                                                        object:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:ANTorrentFileViewDidDisappearNotification
                                                        object:self];
    [self stopRefreshing];
}

#pragma mark - Table View -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 4;
    else return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) return @"Info";
    else return @"Priority";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Segmented"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Segmented"];
        }
        prioritySegment.frame = CGRectMake(10, 10, self.view.frame.size.width - 40, 44);
        [cell.contentView addSubview:prioritySegment];
        return cell;
    }
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    NSString * key = nil, * value = nil;
    if (indexPath.row == 0) {
        key = @"Size";
        value = [NSString stringWithFormat:@"%@", filesizeStringForSize(torrentFile.sizeBytes)];
    } else if (indexPath.row == 1) {
        key = @"Completed Chunks";
        value = [NSString stringWithFormat:@"%d", (int)torrentFile.completedChunks];
    } else if (indexPath.row == 2) {
        key = @"Chunks";
        value = [NSString stringWithFormat:@"%d", (int)torrentFile.sizeChunks];
    } else if (indexPath.row == 3) {
        key = @"% Complete";
        value = [NSString stringWithFormat:@"%d%%", (int)round((float)torrentFile.completedChunks / (float)torrentFile.sizeChunks * 100)];
    }
    cell.textLabel.text = key;
    cell.detailTextLabel.text = value;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) return 64;
    else return 44;
}


@end
