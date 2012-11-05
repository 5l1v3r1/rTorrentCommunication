//
//  ANFileViewController.m
//  iRTorrent
//
//  Created by Alex Nichol on 10/30/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANFileViewController.h"
#import "ANAppDelegate.h"
#import "ANDownloadsViewController.h"

@interface ANFileViewController ()

@end

@implementation ANFileViewController

- (id)initWithLocalPath:(NSString *)path {
    if ((self = [super init])) {
        thePath = path;
    }
    return self;
}

- (void)loadView {
    ANAppDelegate * delegate = (ANAppDelegate *)[UIApplication sharedApplication].delegate;
    self.view = [[UIView alloc] initWithFrame:delegate.downloadsViewController.tableView.bounds];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:thePath]]];
    webView.allowsInlineMediaPlayback = YES;
    webView.multipleTouchEnabled = YES;
    webView.mediaPlaybackRequiresUserAction = YES;
    webView.scalesPageToFit = YES;
    [self.view addSubview:webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
