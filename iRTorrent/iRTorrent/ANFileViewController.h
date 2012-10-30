//
//  ANFileViewController.h
//  iRTorrent
//
//  Created by Alex Nichol on 10/30/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANFileViewController : UIViewController {
    UIWebView * webView;
    NSString * thePath;
}

- (id)initWithLocalPath:(NSString *)path;

@end
