//
//  ANTransferCell.h
//  iRTorrent
//
//  Created by Alex Nichol on 10/29/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANTransferCellView.h"

#define ANTransferCellStartStopPressedNotification @"ANTransferCellStartStopPressedNotification"

@interface ANTransferCell : UITableViewCell {
    ANTransferCellView * cellView;
}

@property (readonly) ANTransferCellView * cellView;

@end
