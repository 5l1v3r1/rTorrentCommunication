//
//  ANTransferCellView.m
//  iRTorrent
//
//  Created by Alex Nichol on 10/29/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANTransferCellView.h"

@implementation ANTransferCellView

@synthesize startStopButton;

- (id)init {
    self = [self initWithFrame:CGRectMake(0, 0, 0, 0)];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        [self addSubview:progress];
        
        statusLabel = [[UILabel alloc] init];
        [statusLabel setBackgroundColor:[UIColor clearColor]];
        [statusLabel setFont:[UIFont systemFontOfSize:14]];
        [statusLabel setTextColor:[UIColor grayColor]];
        [self addSubview:statusLabel];
        
        titleLabel = [[UILabel alloc] init];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [titleLabel setNumberOfLines:0];
        [self addSubview:titleLabel];
        
        startStopButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        [startStopButton setBackgroundImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
        [self addSubview:startStopButton];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [titleLabel setFrame:CGRectMake(10, 5, frame.size.width - 52, 16)];
    [progress setFrame:CGRectMake(10, 24, frame.size.width - 52, progress.frame.size.height)];
    [statusLabel setFrame:CGRectMake(10, 24 + progress.frame.size.height + 3, frame.size.width - 52, 16)];
    [startStopButton setFrame:CGRectMake(frame.size.width - 27, (frame.size.height - 22) / 2, 22, 22)];
}

- (void)updateInfoForTransfer:(ANTransfer *)aTransfer {
    [titleLabel setText:[aTransfer.remotePath lastPathComponent]];
    [progress setProgress:((float)aTransfer.hasSize / (float)aTransfer.totalSize)];
    NSString * status = [NSString stringWithFormat:@"%@ of %@",
                         filesizeStringForSize(aTransfer.hasSize),
                         filesizeStringForSize(aTransfer.totalSize)];
    [statusLabel setText:status];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
