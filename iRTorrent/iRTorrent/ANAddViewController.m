//
//  ANAddViewController.m
//  iRTorrent
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANAddViewController.h"

@interface ANAddViewController ()

@end

@implementation ANAddViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    urlField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 32)];
    urlField.borderStyle = UITextBorderStyleRoundedRect;
    urlField.placeholder = @"URL";
    urlField.font = [UIFont systemFontOfSize:22];
    [self.view addSubview:urlField];
    
    UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(donePressed:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)donePressed:(id)sender {
    [delegate addViewController:self addedURL:urlField.text];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
