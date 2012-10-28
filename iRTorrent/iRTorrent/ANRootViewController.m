//
//  ANViewController.m
//  iRTorrent
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANRootViewController.h"

@interface ANRootViewController ()

@end

@implementation ANRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * host = [[NSUserDefaults standardUserDefaults] objectForKey:@"server_name"];
    NSString * username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString * password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    if (!host) host = @"107.22.194.29";
    if (!username) username = @"root";
    if (!password) password = @"";
    session = [[ANRPCSession alloc] initWithHost:host port:9082 username:username password:password];
    session.delegate = self;
    
    ANRTorrentOperation * list = [[ANRTorrentOperation alloc] initWithOperation:ANRTorrentOperationList arguments:nil];
    [session pushCall:list];
    
    self.tableView.rowHeight = 68;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Session -

- (void)rpcSession:(ANRPCSession *)session call:(id<ANRPCCall>)call failedWithError:(NSError *)error {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription]
                                                    delegate:nil
                                           cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)rpcSession:(ANRPCSession *)session call:(id<ANRPCCall>)call gotResponse:(id)response {
    if ([call isKindOfClass:[ANRTorrentOperation class]]) {
        if ([(ANRTorrentOperation *)call type] == ANRTorrentOperationList) {
            torrentList = response;
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Table View -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [torrentList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ANTorrentCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[ANTorrentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    ANRTorrentInfo * info = [torrentList objectAtIndex:indexPath.row];
    NSString * status = [NSString stringWithFormat:@"%.2f of %.2f MiB",
                         ((float)info.bytesDone / 1024.0 / 1024), ((float)info.totalBytes / 1024.0 / 1024)];
    
    cell.cellView.titleLabel.text = [[torrentList objectAtIndex:indexPath.row] name];
    cell.cellView.downloadStatus.text = status;
    if ([info.state isEqualToString:@"0"]) {
        [cell.cellView setStatusImageOn:NO];
    } else {
        [cell.cellView setStatusImageOn:YES];
    }
    [cell.cellView layoutView];
    return cell;
}

@end
