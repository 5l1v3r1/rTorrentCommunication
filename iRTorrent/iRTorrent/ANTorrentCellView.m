//
//  ANTorrentCellView.m
//  iRTorrent
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANTorrentCellView.h"

@implementation ANTorrentCellView

@synthesize titleLabel;
@synthesize downloadStatus;
@synthesize statusImage;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        titleLabel = [[UILabel alloc] init];
        downloadStatus = [[UILabel alloc] init];
        statusImage = [[UIImageView alloc] init];
        
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:14];
        
        downloadStatus.backgroundColor = [UIColor clearColor];
        downloadStatus.font = [UIFont italicSystemFontOfSize:14];
        
        statusImage.contentMode = UIViewContentModeScaleToFill;
        
        [self addSubview:titleLabel];
        [self addSubview:downloadStatus];
        [self addSubview:statusImage];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self layoutView];
}

- (void)layoutView {
    CGRect frame = self.frame;
    CGSize size = [titleLabel.text sizeWithFont:titleLabel.font];
    statusImage.frame = CGRectMake(0, frame.size.height / 2 - 20, 41, 41);
    if (size.width > titleLabel.frame.size.width) {
        titleLabel.frame = CGRectMake(42, 5, frame.size.width - 52, 40);
        titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        downloadStatus.frame = CGRectMake(42, 45, frame.size.width - 52, 16);
        titleLabel.numberOfLines = 2;
    } else {
        titleLabel.frame = CGRectMake(42, 5, frame.size.width - 52, 18);
        downloadStatus.frame = CGRectMake(42, 25, frame.size.width - 52, 16);
        titleLabel.numberOfLines = 1;
    }
}

- (void)setStatusImageOn:(BOOL)on {
    if (on) {
        statusImage.image = [UIImage imageNamed:@"on"];
    } else {
        statusImage.image = [UIImage imageNamed:@"off"];
    }
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
