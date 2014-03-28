BEVSliderCell
=============

This Xcode project provides a sliding UITableViewCell and demonstrates how to use it.

BEVSliderCell is a UITableViewCell subclass that uses the pan gesture to allow dragging the cell's content view left or right. Actions can be attached to a BEVSliderCell instance so the action is invoked when a user drags the cell to the maximum left or right position. Controls such as buttons can be added to the cell's backgroundView, and will be revealed when the cell slides out.

BEVSliderCell.h:

```
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
```

Tested with: OS X 10.9.1; Xcode 5.0.2; iOS SDK 7.0.4
