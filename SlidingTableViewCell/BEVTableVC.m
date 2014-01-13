//
//  BEVTableVC.m
//  SlidingTableViewCell
//
//  Created by Brett Neely <sourcecode@bitsevolving.com> on 1/13/14.
//  Copyright (c) 2014 Bits Evolving. Distributed under the MIT license -- see LICENSE file for details.
//

#import "BEVTableVC.h"

#import "BEVSliderCell.h"

@interface BEVTableVC ()
@property (nonatomic, readwrite) NSArray *items;
@end

@implementation BEVTableVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.items = @[@"Blank", @"Slide left", @"Slide right", @"Both"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.scrollEnabled = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"BEVSliderCell" bundle:nil] forCellReuseIdentifier:[self cellReuseId]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

// This class only uses one cell reuse identifier with its tableView
- (NSString *)cellReuseId
{
    static NSString *identifier = @"sliderCell";
    return identifier;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BEVSliderCell *cell = [tv dequeueReusableCellWithIdentifier:[self cellReuseId]];
    NSInteger row = indexPath.row;
    
    if (0 == row) {
        cell.allowPanningLeft = NO;
        cell.allowPanningRight = NO;
    } else if (1 == row) {
        // Slide left
        cell.allowPanningLeft = YES;
        
        // Add a button behind the cell
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat buttonWidth = 80.0f;
        CGRect bFrame = CGRectMake(cell.frame.size.width - buttonWidth, 0, buttonWidth, cell.frame.size.height);
        button.frame = bFrame;
        button.backgroundColor = [UIColor purpleColor];
        [button setTitle:@"Button" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonBehindCellPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.backgroundView addSubview:button];
        cell.backgroundView.backgroundColor = [UIColor blackColor];
        
        // Only allow the cell to slide out enough to fully reveal the button
        cell.minimumVisibleWidth = cell.frame.size.width - bFrame.size.width;
    } else if (2 == row) {
        // Slide right
        cell.allowPanningRight = YES;
    } else if (3 == row) {
        // Both
        cell.allowPanningLeft = YES;
        cell.allowPanningRight = YES;
    }
    
    if (cell.allowPanningLeft) {
        [cell addTarget:self action:@selector(cellReachedLeftEdge:) atMinimumWidthForDirection:BEVDirectionLeft];
    }
    
    if (cell.allowPanningRight) {
        [cell addTarget:self action:@selector(cellReachedRightEdge:) atMinimumWidthForDirection:BEVDirectionRight];
    }
    
    cell.backgroundColor = [UIColor orangeColor];
    cell.frontLabel.text = [self.items objectAtIndex:row];

    
    return cell;
}

#pragma mark BEVSliderCell actions

- (void)cellReachedLeftEdge:(id)sender
{
    NSLog(@"Cell reached left edge: %@", sender);
}

- (void)cellReachedRightEdge:(id)sender
{
    NSLog(@"Cell reached right edge: %@", sender);
}

#pragma mark Button action

- (void)buttonBehindCellPressed:(id)sender
{
    NSLog(@"Button pressed: %@", sender);
}

@end
