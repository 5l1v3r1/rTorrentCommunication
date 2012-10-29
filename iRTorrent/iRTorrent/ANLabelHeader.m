//
//  ANLabelHeader.m
//  iRTorrent
//
//  Created by Alex Nichol on 10/29/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "ANLabelHeader.h"

@implementation ANLabelHeader

@synthesize label;

- (id)initWithWidth:(CGFloat)width text:(NSString *)text font:(UIFont *)font {
    CGSize size = [text sizeWithFont:font
                   constrainedToSize:CGSizeMake(width - 20, CGFLOAT_MAX)
                       lineBreakMode:NSLineBreakByCharWrapping];
    if ((self = [super initWithFrame:CGRectMake(0, 0, width, size.height + 20)])) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, width - 20, size.height)];
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.text = text;
        label.font = font;
        label.numberOfLines = 0;
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        self.backgroundColor = [UIColor colorWithRed:0.89 green:0.88 blue:0.82 alpha:1];
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowOpacity = 0.5;
    }
    return self;
}

@end
