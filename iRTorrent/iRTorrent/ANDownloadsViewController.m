//
//  ANDownloadsViewController.m
//  iRTorrent
//
//  Created by Alex Nichol on 10/29/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANDownloadsViewController.h"

#include <stdio.h>

@interface ANDownloadsViewController ()

@end

@implementation ANDownloadsViewController

- (id)init {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        transfers = [[NSMutableArray alloc] init];
        self.tableView.rowHeight = 58;
    }
    return self;
}

- (void)addTransfer:(ANTransfer *)aTransfer {
    aTransfer.host = [ANSettingsController host];
    aTransfer.username = [ANSettingsController username];
    aTransfer.password = [ANSettingsController password];
    aTransfer.port = 9083;
    aTransfer.delegate = self;
    [aTransfer startTransfer];
    
    [transfers addObject:aTransfer];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [transfers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ANTransferCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[ANTransferCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    [cell.cellView updateInfoForTransfer:[transfers objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - Transfer -

- (void)transferCompleted:(ANTransfer *)transfer {
    NSInteger index = [transfers indexOfObject:transfer];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                          withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)transfer:(ANTransfer *)transfer failedWithError:(NSError *)error {
    NSInteger index = [transfers indexOfObject:transfer];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                          withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                     message:[error localizedDescription]
                                                    delegate:nil
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)transfer:(ANTransfer *)transfer progressChanged:(float)progress {
    NSInteger index = [transfers indexOfObject:transfer];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                          withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

@end
