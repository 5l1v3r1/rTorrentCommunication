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

static BOOL arrayIncludesTorrentHash(NSArray * list, NSString * hash);

@implementation ANRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Torrents";
    
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
    
    addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                              target:self
                                                              action:@selector(addPressed:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                    target:self
                                                  selector:@selector(refreshItems:)
                                                  userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshItems:(id)sender {
    if (hasRefreshed) {
        hasRefreshed = NO;
        ANRTorrentOperation * list = [[ANRTorrentOperation alloc] initWithOperation:ANRTorrentOperationList arguments:nil];
        [session pushCall:list];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    activeTorrentVC = nil;
}

#pragma mark - Session -

- (void)rpcSession:(ANRPCSession *)session call:(id<ANRPCCall>)call failedWithError:(NSError *)error {
    hasRefreshed = YES;
    if (!hasAlerted) {
        hasAlerted = YES;
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription]
                                                        delegate:nil
                                               cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (void)rpcSession:(ANRPCSession *)session call:(id<ANRPCCall>)call gotResponse:(id)response {
    hasRefreshed = YES;
    hasAlerted = NO;
    if ([call isKindOfClass:[ANRTorrentOperation class]]) {
        if ([(ANRTorrentOperation *)call type] == ANRTorrentOperationList) {
            if (!torrentList) {
                torrentList = response;
                [self.tableView reloadData];
            } else {
                [self intelligentlyReloadTable:response];
            }
            if (activeTorrentVC) {
                BOOL found = NO;
                for (ANRTorrentInfo * info in response) {
                    if ([info.torrentHash isEqualToString:activeTorrentVC.torrentInfo.torrentHash]) {
                        found = YES;
                        [activeTorrentVC updateWithTorrentInfo:info];
                    }
                }
                if (!found) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }
        } else {
            [self refreshItems:self];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ANRTorrentInfo * info = [torrentList objectAtIndex:indexPath.row];
    ANTorrentViewController * vc = [[ANTorrentViewController alloc] initWithTorrentInfo:info];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
    activeTorrentVC = vc;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ANRTorrentInfo * info = [torrentList objectAtIndex:indexPath.row];
        NSArray * args = @[info.torrentHash];
        ANRTorrentOperation * deleteOperation = [[ANRTorrentOperation alloc] initWithOperation:ANRTorrentOperationErase
                                                                                     arguments:args];
        [session pushCall:deleteOperation];
        NSMutableArray * list = [torrentList mutableCopy];
        [list removeObjectAtIndex:indexPath.row];
        torrentList = [list copy];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)intelligentlyReloadTable:(NSArray *)newList {
    [self.tableView beginUpdates];
    // delete non-existant
    NSMutableArray * editList = [[NSMutableArray alloc] initWithArray:torrentList];
    NSUInteger numRemoved = 0;
    NSMutableArray * deleteIndexPaths = [NSMutableArray array];
    for (NSUInteger i = 0; i < [editList count]; i++) {
        ANRTorrentInfo * info = [editList objectAtIndex:i];
        if (!arrayIncludesTorrentHash(newList, info.torrentHash)) {
            [editList removeObjectAtIndex:i];
            NSIndexPath * path = [NSIndexPath indexPathForRow:(i + numRemoved) inSection:0];
            [deleteIndexPaths addObject:path];
            i--;
            numRemoved++;
        }
    }
    [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    // insert new
    NSMutableArray * insertIndexPaths = [NSMutableArray array];
    for (ANRTorrentInfo * info in newList) {
        if (!arrayIncludesTorrentHash(editList, info.torrentHash)) {
            [editList addObject:info];
            [insertIndexPaths addObject:[NSIndexPath indexPathForRow:([editList count] - 1)
                                                           inSection:0]];
        }
    }
    [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    // update existing
    NSMutableArray * updateIndexPaths = [NSMutableArray array];
    for (NSUInteger i = 0; i < [editList count]; i++) {
        NSInteger useIndex = -1;
        ANRTorrentInfo * info = [editList objectAtIndex:i];
        for (NSInteger j = 0; j < [newList count]; j++) {
            if ([[[newList objectAtIndex:j] torrentHash] isEqualToString:info.torrentHash]) {
                useIndex = j;
                break;
            }
        }
        if (useIndex < 0) continue;
        if (![[newList objectAtIndex:useIndex] isEqualToInfo:info]) {
            [updateIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            [editList replaceObjectAtIndex:i withObject:[newList objectAtIndex:useIndex]];
        }
    }
    [self.tableView reloadRowsAtIndexPaths:updateIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    torrentList = [editList copy];
    [self.tableView endUpdates];
}

#pragma mark - Torrent View -

- (void)torrentViewControllerStartRequested:(ANTorrentViewController *)tvc {
    NSArray * args = @[[tvc.torrentInfo.torrentHash uppercaseString]];
    ANRTorrentOperation * startOperation = [[ANRTorrentOperation alloc] initWithOperation:ANRTorrentOperationStart
                                                                                arguments:args];
    [session pushCall:startOperation];
}

- (void)torrentViewControllerStopRequested:(ANTorrentViewController *)tvc {
    NSArray * args = @[[tvc.torrentInfo.torrentHash uppercaseString]];
    ANRTorrentOperation * stopOperation = [[ANRTorrentOperation alloc] initWithOperation:ANRTorrentOperationStop
                                                                               arguments:args];
    ANRTorrentOperation * closeOperation = [[ANRTorrentOperation alloc] initWithOperation:ANRTorrentOperationClose
                                                                               arguments:args];
    [session pushCall:stopOperation];
    [session pushCall:closeOperation];
}

#pragma mark - Adding -

- (void)addPressed:(id)sender {
    ANAddViewController * addVC = [[ANAddViewController alloc] init];
    addVC.delegate = self;
    [self.navigationController pushViewController:addVC animated:YES];
}

- (void)addViewController:(ANAddViewController *)addVc addedURL:(NSString *)str {
    ANRTorrentOperation * addOperation = [[ANRTorrentOperation alloc] initWithOperation:ANRTorrentOperationLoad
                                                                              arguments:@[str]];
    [session pushCall:addOperation];
    [self.navigationController popViewControllerAnimated:YES];
}

@end

static BOOL arrayIncludesTorrentHash(NSArray * list, NSString * hash) {
    for (ANRTorrentInfo * info in list) {
        if ([info.torrentHash isEqualToString:hash]) return YES;
    }
    return NO;

}