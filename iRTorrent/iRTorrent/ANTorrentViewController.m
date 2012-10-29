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
        torrentName = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, frame.size.width - 20, 50)];
        torrentName.font = [UIFont boldSystemFontOfSize:16];
        torrentName.backgroundColor = [UIColor clearColor];
        torrentName.lineBreakMode = NSLineBreakByCharWrapping;
        torrentName.numberOfLines = 0;
        
        UIView * header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 70)];
        header.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
        header.layer.shadowColor = [[UIColor blackColor] CGColor];
        header.layer.shadowOffset = CGSizeMake(0, 1);
        header.layer.shadowOpacity = 0.5;
        header.layer.shadowRadius = 5;
        [header addSubview:torrentName];
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
    torrentName.text = torrentInfo.name;
    [self.tableView reloadData];
    if ([torrentInfo.state isEqualToString:@"0"]) {
        self.navigationItem.rightBarButtonItem = startButton;
    } else {
        self.navigationItem.rightBarButtonItem = stopButton;
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
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    NSString * key = nil, * value = nil;
    if (indexPath.row == 0) {
        key = @"State";
        value = [torrentInfo.state isEqualToString:@"0"] ? @"Inactive" : @"Active";
    } else if (indexPath.row == 1) {
        key = @"Total Size";
        value = [NSString stringWithFormat:@"%.1f MB", (float)torrentInfo.totalBytes / 1024 / 1024];
    } else if (indexPath.row == 2) {
        key = @"Bytes Downloaded";
        value = [NSString stringWithFormat:@"%.1f MB", (float)torrentInfo.bytesDone / 1024 / 1024];
    } else if (indexPath.row == 3) {
        key = @"Download Rate";
        value = [NSString stringWithFormat:@"%0.2f KB/s", torrentInfo.downRate / 1024];
    } else if (indexPath.row == 4) {
        key = @"Upload Rate";
        value = [NSString stringWithFormat:@"%0.2f KB/s", torrentInfo.uploadRate / 1024];
    }
    cell.detailTextLabel.text = value;
    cell.textLabel.text = key;
    return cell;
}

@end
