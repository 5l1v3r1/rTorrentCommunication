//
//  ANTorrentCell.m
//  iRTorrent
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANTorrentCell.h"

@implementation ANTorrentCell

@synthesize cellView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        cellView = [[ANTorrentCellView alloc] initWithFrame:CGRectZero];
        cellView.frame = self.contentView.frame;
        [self.contentView addSubview:cellView];
        cellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentView.autoresizesSubviews = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    UIColor * textColor = selected ? [UIColor whiteColor] : [UIColor blackColor];
    cellView.titleLabel.textColor = textColor;
    cellView.downloadStatus.textColor = textColor;
}

@end
