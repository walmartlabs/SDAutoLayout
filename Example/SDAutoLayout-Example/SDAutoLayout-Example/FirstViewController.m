//
//  FirstViewController.m
//  SDAutoLayout-Example
//
//  Created by Sam Grover on 10/9/14.
//  Copyright (c) 2014 Set Direction. All rights reserved.
//

#import "FirstViewController.h"
#import "SDAutoLayout.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat inset = 10.0f;
    NSUInteger maxWidth = self.view.bounds.size.width - inset;
    
    UIScrollView* scrollView = [[UIScrollView alloc] initForSDAutoLayout];
    [self.view addSubview:scrollView];
    [scrollView sdal_pinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(inset, inset, inset, inset)];
    
    // Create and add a bunch of views with random background color, same widths, random heights
    NSUInteger numViews = 100;
    NSMutableArray* allViews = [NSMutableArray arrayWithCapacity:numViews];
    for (NSUInteger i = 0; i < numViews; i++)
    {
        UIView* aView = [UIView newSDAutoLayoutView];
        aView.backgroundColor = [self randomHSBColor];
        [aView sdal_setDimensionsToSize:CGSizeMake(maxWidth, floor([self randomFloat] * inset))];
        [allViews addObject:aView];
        [scrollView addSubview:aView];
    }
    
    // Lay them all out so their centers are aligned to each other
    __block NSArray* alignmentConstraints = [allViews sdal_distributeViewsAlongAxis:SDALAxisVertical withFixedSpacing:inset insetSpacing:YES matchedSizes:NO alignment:NSLayoutFormatAlignAllCenterX];
    
    // After a few seconds, animate them into different widths, while making them left aligned
    NSUInteger timeInSeconds = 3;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [scrollView removeConstraints:alignmentConstraints];
        alignmentConstraints = [allViews sdal_distributeViewsAlongAxis:SDALAxisVertical withFixedSpacing:inset insetSpacing:YES matchedSizes:NO alignment:NSLayoutFormatAlignAllLeft];
        [UIView animateWithDuration:1.0f animations:^{
            for (UIView* aView in allViews)
            {
                for (NSLayoutConstraint* aConstraint in aView.constraints)
                {
                    if (aConstraint.firstAttribute == NSLayoutAttributeWidth)
                    {
                        aConstraint.constant = [self randomFloat] * maxWidth;
                    }
                }
            }
            [self.view layoutIfNeeded];
        }];
    });
    
    // After a few seconds, animate them to the center of their superview, the scroll view
    timeInSeconds += 3;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:1.0f animations:^{
            [scrollView removeConstraints:alignmentConstraints];
            alignmentConstraints = [allViews sdal_distributeViewsAlongAxis:SDALAxisVertical withFixedSpacing:inset insetSpacing:YES matchedSizes:NO alignment:NSLayoutFormatAlignAllCenterX];
            for (UIView* aView in allViews)
            {
                [aView sdal_alignAxisToSuperviewAxis:SDALAxisVertical];
            }
            [self.view layoutIfNeeded];
        }];
    });
    
    // After a few seconds, animate them all to the same height
    timeInSeconds += 3;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:1.0f animations:^{
            for (UIView* aView in allViews)
            {
                for (NSLayoutConstraint* aConstraint in aView.constraints)
                {
                    if (aConstraint.firstAttribute == NSLayoutAttributeHeight)
                    {
                        aConstraint.constant = inset;
                    }
                }
            }
            [self.view layoutIfNeeded];
        }];
    });
    
}

#pragma mark - Helpers

- (CGFloat)randomFloat
{
    CGFloat r = (arc4random() % 100) / 100.0f;
    return r;
}

- (UIColor *)randomRGBColor
{
    return [UIColor colorWithRed:[self randomFloat]
                           green:[self randomFloat]
                            blue:[self randomFloat]
                           alpha:1.0f];
}

- (UIColor *)randomHSBColor
{
    return [UIColor colorWithHue:[self randomFloat]
                      saturation:1.0f
                      brightness:1.0f
                           alpha:1.0f];
}

@end
