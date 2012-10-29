//
//  ANTorrentDirViewController.m
//  iRTorrent
//
//  Created by Alex Nichol on 10/29/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANTorrentDirViewController.h"

@interface ANTorrentDirViewController ()

@end

@implementation ANTorrentDirViewController

- (id)initWithDirectory:(ANRTorrentDirectory *)aDirectory {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        directory = aDirectory;
        self.title = directory.directoryName;
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [directory.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    id item = [directory.items objectAtIndex:indexPath.row];
    if ([item isKindOfClass:[ANRTorrentDirectory class]]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = [[item directoryName] stringByAppendingString:@"/"];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = [[(ANRTorrentFile *)item pathComponents] lastObject];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = [directory.items objectAtIndex:indexPath.row];
    if ([item isKindOfClass:[ANRTorrentDirectory class]]) {
        ANTorrentDirViewController * subDirView = [[ANTorrentDirViewController alloc] initWithDirectory:item];
        [self.navigationController pushViewController:subDirView animated:YES];
    } else {
        ANTorrentFileViewController * fileView = [[ANTorrentFileViewController alloc] initWithFile:item];
        [self.navigationController pushViewController:fileView animated:YES];
    }
}

@end
