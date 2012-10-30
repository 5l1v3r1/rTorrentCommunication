//
//  ANTransferCell.m
//  iRTorrent
//
//  Created by Alex Nichol on 10/29/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANTransferCell.h"

@interface ANTransferCell (Private)

- (void)buttonPressed:(id)sender;

@end

@implementation ANTransferCell

@synthesize cellView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        cellView = [[ANTransferCellView alloc] initWithFrame:self.contentView.bounds];
        cellView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.contentView.autoresizesSubviews = YES;
        [self.contentView addSubview:cellView];
        [cellView.startStopButton addTarget:self
                                     action:@selector(buttonPressed:)
                           forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            [cellView setHighlighted:selected];
        }];
    } else {
        [cellView setHighlighted:selected];
    }
}

- (void)buttonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:ANTransferCellStartStopPressedNotification
                                                        object:self];
}

@end
