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

+ (NSString *)downloadsSavePath;

@end

@implementation ANDownloadsViewController

+ (NSString *)downloadsSavePath {
    return [NSString stringWithFormat:@"%@/Documents/downloads.sav", NSHomeDirectory()];
}

- (id)init {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        self.tableView.rowHeight = 58;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(downloadCellPlayPause:)
                                                     name:ANTransferCellStartStopPressedNotification
                                                   object:nil];
        NSString * loadPath = [self.class downloadsSavePath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:loadPath]) {
            transfers = [[NSKeyedUnarchiver unarchiveObjectWithFile:loadPath] mutableCopy];
            if (transfers) {
                for (ANTransfer * t in transfers) {
                    t.delegate = self;
                }
            }
        }
        if (!transfers) transfers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addTransfer:(ANTransfer *)aTransfer {
    aTransfer.host = [ANSettingsController host];
    aTransfer.username = [ANSettingsController username];
    aTransfer.password = [ANSettingsController password];
    aTransfer.port = 9083;
    aTransfer.delegate = self;
    
    [transfers addObject:aTransfer];
    [self saveTransfers];
    [self.tableView reloadData];
}

- (void)downloadCellPlayPause:(NSNotification *)notification {
    ANTransferCell * cell = notification.object;
    NSIndexPath * index = [self.tableView indexPathForRowAtPoint:cell.center];
    NSAssert(index != nil, @"It seems that the table view does not contain the selected cell");
    ANTransfer * transfer = [transfers objectAtIndex:index.row];
    if (transfer.state == ANTransferStateNotRunning) {
        [transfer startTransfer];
    } else {
        [transfer cancelTransfer];
    }
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)saveTransfers {
    NSString * savePath = [self.class downloadsSavePath];
    [NSKeyedArchiver archiveRootObject:transfers toFile:savePath];
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
    ANTransfer * transfer = [transfers objectAtIndex:indexPath.row];
    if (transfer.totalSize == transfer.hasSize) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell.cellView updateInfoForTransfer:[transfers objectAtIndex:indexPath.row]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    ANTransfer * t = [transfers objectAtIndex:indexPath.row];
    if (t.totalSize == t.hasSize) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ANTransfer * t = [transfers objectAtIndex:indexPath.row];
        if (t.state != ANTransferStateNotRunning) [t cancelTransfer];
        if (![[NSFileManager defaultManager] removeItemAtPath:t.localPath error:nil] && [[NSFileManager defaultManager] fileExistsAtPath:t.localPath]) {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:@"Could not delete the local file. Please try again."
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"OK", nil];
            [av show];
        } else {
            [tableView beginUpdates];
            [transfers removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView endUpdates];
            [self saveTransfers];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ANTransfer * t = [transfers objectAtIndex:indexPath.row];
    ANFileViewController * fileVC = [[ANFileViewController alloc] initWithLocalPath:t.localPath];
    [self.navigationController pushViewController:fileVC animated:YES];
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
