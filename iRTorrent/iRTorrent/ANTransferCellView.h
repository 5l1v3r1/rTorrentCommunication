//
//  ANTransferCellView.h
//  iRTorrent
//
//  Created by Alex Nichol on 10/29/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANTransfer.h"
#import "NSNumber+FileSize.h"

@interface ANTransferCellView : UIView {
    UIProgressView * progress;
    UILabel * statusLabel;
    UILabel * titleLabel;
    UIButton * startStopButton;
}

@property (readonly) UIButton * startStopButton;

- (void)updateInfoForTransfer:(ANTransfer *)aTransfer;

@end
