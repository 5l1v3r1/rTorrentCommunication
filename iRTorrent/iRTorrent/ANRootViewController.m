//
//  ANViewController.m
//  iRTorrent
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANRootViewController.h"
#import "ANAppDelegate.h"
#import "ANDownloadsViewController.h"

@interface ANRootViewController ()

@end

static BOOL arrayIncludesTorrentHash(NSArray * list, NSString * hash);

@implementation ANRootViewController

@synthesize session;
@synthesize fileVC;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Torrents";
    
    [self restartSession];
    
    ANRTorrentOperation * list = [[ANRTorrentOperation alloc] initWithOperation:ANRTorrentOperationList arguments:nil];
    [session pushCall:list];
    
    self.tableView.rowHeight = 68;
    
    addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                              target:self
                                                              action:@selector(addPressed:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    [self createRefreshTimer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fileViewSetPriority:)
                                                 name:ANTorrentFileViewControllerChangedPriorityNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fileViewDownloadTapped:)
                                                 name:ANTorrentFileViewControllerDownloadTappedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fileViewAppeared:)
                                                 name:ANTorrentFileViewDidAppearNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fileViewDisappeared:)
                                                 name:ANTorrentFileViewDidDisappearNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fileViewRefreshRequest:)
                                                 name:ANTorrentFileViewRequestInfoNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)severSession {
    if (!session) return;
    session.delegate = nil;
    [session cancelAll];
    session = nil;
}

- (void)restartSession {
    if (session) {
        [session cancelAll];
        session.delegate = nil;
    }
    hasRefreshed = YES;
    NSString * host = [ANSettingsController host];
    NSString * username = [ANSettingsController username];
    NSString * password = [ANSettingsController password];
    session = [[ANRPCSession alloc] initWithHost:host port:9082 username:username password:password];
    session.delegate = self;
}

- (void)fileViewSetPriority:(NSNotification *)notification {
    fileVC = [notification object];
    ANRTorrentFile * file = fileVC.torrentFile;
    ANRTorrentInfo * info = activeTorrentVC.torrentInfo;
    NSAssert(file != nil && info != nil, @"-fileViewSetPriority: called at inappropriate time");
    NSArray * arguments = @[info.torrentHash, [NSNumber numberWithInt:file.fileIndex],
                            [NSNumber numberWithInt:file.priority]];
    ANRTorrentOperation * setPriority = [[ANRTorrentOperation alloc] initWithOperation:ANRTorrentOperationSetPriority
                                                                             arguments:arguments];
    [session pushCall:setPriority];
}

- (void)fileViewDownloadTapped:(NSNotification *)notification {
    fileVC = [notification object];
    ANRTorrentFile * file = fileVC.torrentFile;
    ANRTorrentInfo * info = activeTorrentVC.torrentInfo;
    NSAssert(file != nil && info != nil, @"-fileViewDownloadTapped: called at inappropriate time");
    // get absolute path
    NSString * path = [info baseFile];
    if ([[info baseDirectory] length] > 0) {
        path = [info baseDirectory];
        for (NSString * comp in file.pathComponents) {
            path = [path stringByAppendingPathComponent:comp];
        }
    }
    NSString * localPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%d.%d.%@", arc4random(), arc4random(), [path lastPathComponent]];
    ANDownloadsViewController * dvc = [(ANAppDelegate *)[UIApplication sharedApplication].delegate downloadsViewController];
    ANTransfer * transfer = [[ANTransfer alloc] initWithLocalFile:localPath remoteFile:path totalSize:file.sizeBytes];
    [dvc addTransfer:transfer];
    UITabBarController * tabs = [(ANAppDelegate *)[UIApplication sharedApplication].delegate tabBar];
    [tabs setSelectedIndex:1];
}

- (void)fileViewAppeared:(NSNotification *)notification {
    fileVC = [notification object];
}

- (void)fileViewDisappeared:(NSNotification *)notification {
    fileVC = nil;
}

- (void)fileViewRefreshRequest:(NSNotification *)notification {
    fileVC = notification.object;
    if (!session) {
        NSError * error = [NSError errorWithDomain:@"ANRootViewController"
                                              code:1
                                          userInfo:@{NSLocalizedDescriptionKey: @"No active session"}];
        [notification.object refreshFileInfoFailed:error];
    } else {
        NSNumber * indexNumber = [NSNumber numberWithInt:(int)fileVC.torrentFile.fileIndex];
        NSArray * arguments = @[activeTorrentVC.torrentInfo.torrentHash, indexNumber];
        ANRTorrentOperation * operation = [[ANRTorrentOperation alloc] initWithOperation:ANRTorrentOperationFileInfo
                                                                               arguments:arguments];
        [session pushCall:operation];
    }
}

#pragma mark - Live Updating -

- (void)viewDidAppear:(BOOL)animated {
    activeTorrentVC = nil;
}

- (void)refreshItems:(id)sender {
    if (hasRefreshed) {
        hasRefreshed = NO;
        ANRTorrentOperation * list = [[ANRTorrentOperation alloc] initWithOperation:ANRTorrentOperationList arguments:nil];
        [session pushCall:list];
    }
}

- (void)createRefreshTimer {
    if (refreshTimer) return;
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                    target:self
                                                  selector:@selector(refreshItems:)
                                                  userInfo:nil repeats:YES];
}

- (void)invalidateRefreshTimer {
    [refreshTimer invalidate];
    refreshTimer = nil;
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
        ANRTorrentOperation * operation = (ANRTorrentOperation *)call;
        if (operation.type == ANRTorrentOperationList) {
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
        } else if (operation.type == ANRTorrentOperationListFiles) {
            NSComparisonResult x = [[operation.arguments lastObject] caseInsensitiveCompare:activeTorrentVC.torrentInfo.torrentHash];
            if (x == NSOrderedSame) {
                ANRTorrentDirectory * dir = [[ANRTorrentDirectory alloc] initRootWithFiles:response];
                [activeTorrentVC fetchedTorrentRoot:dir];
            }
        } else if (operation.type == ANRTorrentOperationFileInfo) {
            ANRTorrentFile * file = response;
            if (!file) {
                NSError * error = [NSError errorWithDomain:@"ANRootViewController"
                                                      code:2
                                                  userInfo:@{NSLocalizedDescriptionKey: @"invalid file index used"}];
                [fileVC refreshFileInfoFailed:error];
            } else {
                [fileVC refreshFileInfoSucceeded:file];
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
    
    NSString * hasStatus = filesizeStringForSize(info.bytesDone);
    NSString * availableStatus = filesizeStringForSize(info.totalBytes);
    NSString * status = [NSString stringWithFormat:@"%@ of %@", hasStatus, availableStatus];
    
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
    
    // fetch the file list
    ANRTorrentOperation * fileList = [[ANRTorrentOperation alloc] initWithOperation:ANRTorrentOperationListFiles
                                                                          arguments:@[info.torrentHash]];
    [session pushCall:fileList];
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
        
        [refreshTimer invalidate];
        refreshTimer = nil;
        [self createRefreshTimer];
        
        NSMutableArray * list = [torrentList mutableCopy];
        [list removeObjectAtIndex:indexPath.row];
        torrentList = [list copy];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)intelligentlyReloadTable:(NSArray *)newList {
    [self.tableView beginUpdates];
    NSMutableArray * editList = [[NSMutableArray alloc] initWithArray:torrentList];
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
    [self.tableView reloadRowsAtIndexPaths:updateIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    // delete non-existant
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
