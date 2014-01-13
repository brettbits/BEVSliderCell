//
//  BEVSliderCell.m
//  SevenPlay
//
//  Created by Brett Neely <sourcecode@bitsevolving.com> on 9/18/13.
//  Copyright (c) 2014 Bits Evolving. Distributed under the MIT license -- see LICENSE file for details.
//

#import "BEVSliderCell.h"

NSString * const BEVSliderCellRestoredOriginNotification = @"BEVSliderCellRestoredOriginNotification";
NSString * const BEVEditingKey = @"editing";

@interface BEVSliderCell ()
@property (nonatomic, readwrite) CGPoint cvOriginBeforePan;
@property (nonatomic, readwrite, strong) NSTimer *restoreOriginTimer;

// Left action
@property (nonatomic, readwrite, weak) id leftTarget;
@property (nonatomic, readwrite) SEL leftAction;

// Right action
@property (nonatomic, readwrite, weak) id rightTarget;
@property (nonatomic, readwrite) SEL rightAction;
@end

@implementation BEVSliderCell

#pragma mark Init / awake / prepare / dealloc

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.frontLabel.textColor = [UIColor blackColor];
    self.restorePositionAfterDelay = 7.5;
    self.minimumVisibleWidth = 90.0f;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height)];
    [self setBackgroundView:bgView];
}

- (void)awakeFromNib
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.cancelsTouchesInView = NO;
    self.gestureRecognizers = @[panGesture];
}

- (void)prepareForReuse
{
    [self destroyTimer];
    [self restoreOriginWithoutAnimationWithNotification:NO];
}

- (void)dealloc
{
    [self destroyTimer];
}

- (void)destroyTimer
{
    [self.restoreOriginTimer invalidate];
    self.restoreOriginTimer = nil;
}

#pragma mark Accessors

- (UILabel *)frontLabel
{
    return fLabel;
}

#pragma mark Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.cvOriginBeforePan = self.contentView.frame.origin;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.isEditing) {
        self.cvOriginBeforePan = self.contentView.frame.origin;

        [self testActionRequirementsAndPerform];
        
        [self.restoreOriginTimer invalidate];
        if (self.restorePositionAfterDelay > 0) {
            self.restoreOriginTimer = [NSTimer scheduledTimerWithTimeInterval:self.restorePositionAfterDelay target:self selector:@selector(restoreOrigin) userInfo:nil repeats:NO];
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan
{
    if (!self.isEditing) {
        CGPoint translation = [pan translationInView:self.contentView];
        CGRect newFrame = self.contentView.frame;
        
        BOOL rightOnly = self.allowPanningRight && !self.allowPanningLeft;
        BOOL leftOnly = self.allowPanningLeft && !self.allowPanningRight;

        CGFloat newXOrigin = self.cvOriginBeforePan.x + translation.x;
        
        if (leftOnly && (newXOrigin > 0.0f)) {
            newXOrigin = 0.0f;
        }
        if (rightOnly && (newXOrigin < 0.0f)) {
            newXOrigin = 0.0f;
        }
        
        CGFloat futureVisibleWidth = self.contentView.frame.size.width - fabsf(newXOrigin);
        if (futureVisibleWidth < self.minimumVisibleWidth) {
            if (newXOrigin > 0.0) {
                newXOrigin -= (self.minimumVisibleWidth - futureVisibleWidth);
            } else {
                newXOrigin += (self.minimumVisibleWidth - futureVisibleWidth);
            }
        }
        
        if (newXOrigin != newFrame.origin.x) {
            newFrame.origin.x = newXOrigin;
            self.contentView.frame = newFrame;
        }
    }
}

#pragma mark Restore origin

- (void)restoreOrigin
{
    if (self.contentView.frame.origin.x != 0.0f) {
        CGFloat viewWidth = self.contentView.frame.size.width;
        CGFloat viewAbsXOrigin = fabsf(self.contentView.frame.origin.x);
        CGFloat dampener = 0.5f;
        CGFloat animationDuration = 0.55f * (((viewAbsXOrigin / viewWidth) * dampener) + dampener / 2.0f);
        [UIView animateWithDuration:animationDuration animations:^(void) {
            for (UIGestureRecognizer *gRec in self.gestureRecognizers) {
                gRec.enabled = NO;
            }
            CGRect cvFrame = self.contentView.frame;
            cvFrame.origin.x = 0.0f;
            self.contentView.frame = cvFrame;
        } completion:^(BOOL finished) {
            for (UIGestureRecognizer *gRec in self.gestureRecognizers) {
                gRec.enabled = YES;
            }
            self.cvOriginBeforePan = self.contentView.frame.origin;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:BEVSliderCellRestoredOriginNotification object:self];
        }];
    }
}

- (void)restoreOriginWithoutAnimationWithNotification:(BOOL)notify
{
    CGRect cvFrame = self.contentView.frame;
    cvFrame.origin.x = 0.0f;
    self.contentView.frame = cvFrame;

    for (UIGestureRecognizer *gRec in self.gestureRecognizers) {
        gRec.enabled = YES;
    }
    self.cvOriginBeforePan = self.contentView.frame.origin;

    if (notify) {
        [[NSNotificationCenter defaultCenter] postNotificationName:BEVSliderCellRestoredOriginNotification object:self];
    }
}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    [super willTransitionToState:state];
    if (UITableViewCellStateEditingMask == state) {
        [self destroyTimer];
        [self restoreOriginWithoutAnimationWithNotification:YES];
    }
}


#pragma mark Actions

- (void)addTarget:(id)target action:(SEL)action atMinimumWidthForDirection:(BEVDirection)direction
{
    if (BEVDirectionLeft == direction) {
        self.leftTarget = target;
        self.leftAction = action;
    } else if (BEVDirectionRight == direction) {
        self.rightTarget = target;
        self.rightAction = action;
    }
}

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

- (void)testActionRequirementsAndPerform
{
    id target = nil;
    SEL action = nil;
    if ([self atLeftMinimum]) {
        target = self.leftTarget;
        action = self.leftAction;
    } else if ([self atRightMinimum]) {
        target = self.rightTarget;
        action = self.rightAction;
    }

    if (target && [target respondsToSelector:action]) {
        SuppressPerformSelectorLeakWarning( [target performSelector:action withObject:self]; );
    }
}

- (BOOL)atLeftMinimum
{
    BOOL result = NO;
    CGFloat visibleWidth = self.contentView.frame.size.width + self.contentView.frame.origin.x;
    if (visibleWidth == self.minimumVisibleWidth) {
        result = YES;
    }
    return result;
}

- (BOOL)atRightMinimum
{
    BOOL result = NO;
    CGFloat visibleWidth = self.contentView.frame.size.width - self.contentView.frame.origin.x;
    if (visibleWidth == self.minimumVisibleWidth) {
        result = YES;
    }
    return result;
}

@end
