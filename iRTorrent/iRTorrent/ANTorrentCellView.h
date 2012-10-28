//
//  ANTorrentCellView.h
//  iRTorrent
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANTorrentCellView : UIView {
    UILabel * titleLabel;
    UILabel * downloadStatus;
    UIImageView * statusImage;
}

@property (readonly) UILabel * titleLabel;
@property (readonly) UILabel * downloadStatus;
@property (readonly) UIImageView * statusImage;

- (void)layoutView;
- (void)setStatusImageOn:(BOOL)on;

@end
