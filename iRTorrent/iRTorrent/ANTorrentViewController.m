//
//  ANTorrentViewController.m
//  iRTorrent
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANTorrentViewController.h"

@interface ANTorrentViewController ()

@end

@implementation ANTorrentViewController

@synthesize torrentInfo;
@synthesize delegate;

- (id)initWithTorrentInfo:(ANRTorrentInfo *)info {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        CGRect frame = self.view.frame;
        
        ANLabelHeader * header = [[ANLabelHeader alloc] initWithWidth:frame.size.width
                                                                 text:info.name
                                                                 font:[UIFont boldSystemFontOfSize:16]];
        self.tableView.tableHeaderView = header;
        
        startButton = [[UIBarButtonItem alloc] initWithTitle:@"Start"
                                                       style:UIBarButtonItemStyleBordered
                                                      target:self
                                                      action:@selector(startPressed:)];
        
        stopButton = [[UIBarButtonItem alloc] initWithTitle:@"Stop"
                                                      style:UIBarButtonItemStyleBordered
                                                     target:self
                                                     action:@selector(stopPressed:)];
        
        [self updateWithTorrentInfo:info];
    }
    return self;
}

- (void)updateWithTorrentInfo:(ANRTorrentInfo *)newInfo {
    if ([newInfo isEqualToInfo:torrentInfo]) return;
    torrentInfo = newInfo;
    [self.tableView reloadData];
    if ([torrentInfo.state isEqualToString:@"0"]) {
        self.navigationItem.rightBarButtonItem = startButton;
    } else {
        self.navigationItem.rightBarButtonItem = stopButton;
    }
}

- (void)fetchedTorrentRoot:(ANRTorrentDirectory *)root {
    if (!rootDirectory) {
        [self.tableView beginUpdates];
        rootDirectory = root;
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:5 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    } else {
        rootDirectory = root;
    }
}

- (void)startPressed:(id)sender {
    [delegate torrentViewControllerStartRequested:self];
}

- (void)stopPressed:(id)sender {
    [delegate torrentViewControllerStopRequested:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Torrent Info";
    self.view.backgroundColor = [UIColor whiteColor];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (rootDirectory) return 6;
    else return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 5) {
        UITableViewCell * filesCell = [tableView dequeueReusableCellWithIdentifier:@"CellFiles"];
        if (!filesCell) {
            filesCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:@"CellFiles"];
        }
        filesCell.textLabel.text = @"Show Files";
        filesCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return filesCell;
    }
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    
    NSString * key = nil, * value = nil;
    if (indexPath.row == 0) {
        key = @"State";
        value = [torrentInfo.state isEqualToString:@"0"] ? @"Inactive" : @"Active";
    } else if (indexPath.row == 1) {
        key = @"Downloaded";
        value = [NSString stringWithFormat:@"%@", filesizeStringForSize(torrentInfo.bytesDone)];
    } else if (indexPath.row == 2) {
        key = @"Total Size";
        value = [NSString stringWithFormat:@"%@", filesizeStringForSize(torrentInfo.totalBytes)];
    } else if (indexPath.row == 3) {
        key = @"Download Rate";
        value = [NSString stringWithFormat:@"%@/s", filesizeStringForSize(torrentInfo.downRate)];
    } else if (indexPath.row == 4) {
        key = @"Upload Rate";
        value = [NSString stringWithFormat:@"%@/s", filesizeStringForSize(torrentInfo.uploadRate)];
    }
    cell.detailTextLabel.text = value;
    cell.textLabel.text = key;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != 5) return NO;
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 5) {
        ANTorrentDirViewController * dirView = [[ANTorrentDirViewController alloc] initWithDirectory:rootDirectory];
        [self.navigationController pushViewController:dirView animated:YES];
    }
}

@end
