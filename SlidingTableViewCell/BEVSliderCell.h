//
//  BEVSliderCell.h
//  SevenPlay
//
//  Created by Brett Neely <sourcecode@bitsevolving.com> on 9/18/13.
//  Copyright (c) 2014 Bits Evolving. Distributed under the MIT license -- see LICENSE file for details.
//

#import <UIKit/UIKit.h>

typedef enum {
    BEVDirectionUnknown,
    BEVDirectionLeft,
    BEVDirectionRight
} BEVDirection;

extern NSString * const BEVSliderCellRestoredOriginNotification;

@interface BEVSliderCell : UITableViewCell
{
    __weak IBOutlet UILabel *fLabel;
}

@property (nonatomic, readwrite) BOOL allowPanningLeft;
@property (nonatomic, readwrite) BOOL allowPanningRight;
@property (nonatomic, readwrite) CGFloat minimumVisibleWidth;
@property (nonatomic, readwrite, strong) UIColor *bgColorDuringPan;
@property (nonatomic, readwrite) NSTimeInterval restorePositionAfterDelay;
@property (nonatomic, readonly) UILabel *frontLabel;

- (void)addTarget:(id)target action:(SEL)action atMinimumWidthForDirection:(BEVDirection)direction;

@end

// TODO: handle velocity (keep moving if moving fast)
// TODO: gradually fade background to bgColorDuringPan depending on pan amount (distance from 0)