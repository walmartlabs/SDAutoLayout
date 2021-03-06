//  NSArray+SDAutoLayout.m
//
//  Created by Sam Grover on 10/01/2014.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//
//  Based on:
//
//  NSArray+PureLayout.m
//  v1.1.0
//  https://github.com/smileyborg/PureLayout
//
//  Copyright (c) 2012 Richard Turton
//  Copyright (c) 2013-2014 Tyler Fox
//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import "NSArray+SDAutoLayout.h"
#import "UIView+SDAutoLayout.h"
#import "NSLayoutConstraint+SDAutoLayout.h"
#import "SDAutoLayout+Internal.h"


#pragma mark - NSArray+SDAutoLayout

@implementation NSArray (SDAutoLayout)


#pragma mark Constrain Multiple Views

/**
 Aligns views in this array to one another along a given edge.
 Note: This array must contain at least 2 views, and all views must share a common superview.
 
 @param edge The edge to which the subviews will be aligned.
 @return An array of constraints added.
 */
- (NSArray *)sdal_alignViewsToEdge:(SDALEdge)edge
{
    NSAssert([self al_containsMinimumNumberOfViews:2], @"This array must contain at least 2 views.");
    NSMutableArray *constraints = [NSMutableArray new];
    UIView *previousView = nil;
    for (id object in self) {
        if ([object isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)object;
            view.translatesAutoresizingMaskIntoConstraints = NO;
            if (previousView) {
                [constraints addObject:[view sdal_pinEdge:edge toEdge:edge ofView:previousView]];
            }
            previousView = view;
        }
    }
    return constraints;
}

/**
 Aligns views in this array to one another along a given axis.
 Note: This array must contain at least 2 views, and all views must share a common superview.
 
 @param axis The axis to which to subviews will be aligned.
 @return An array of constraints added.
 */
- (NSArray *)sdal_alignViewsToAxis:(SDALAxis)axis
{
    NSAssert([self al_containsMinimumNumberOfViews:2], @"This array must contain at least 2 views.");
    NSMutableArray *constraints = [NSMutableArray new];
    UIView *previousView = nil;
    for (id object in self) {
        if ([object isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)object;
            view.translatesAutoresizingMaskIntoConstraints = NO;
            if (previousView) {
                [constraints addObject:[view sdal_alignAxis:axis toSameAxisOfView:previousView]];
            }
            previousView = view;
        }
    }
    return constraints;
}

/**
 Matches a given dimension of all the views in this array.
 Note: This array must contain at least 2 views, and all views must share a common superview.
 
 @param dimension The dimension to match for all of the subviews.
 @return An array of constraints added.
 */
- (NSArray *)sdal_matchViewsDimension:(SDALDimension)dimension
{
    NSAssert([self al_containsMinimumNumberOfViews:2], @"This array must contain at least 2 views.");
    NSMutableArray *constraints = [NSMutableArray new];
    UIView *previousView = nil;
    for (id object in self) {
        if ([object isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)object;
            view.translatesAutoresizingMaskIntoConstraints = NO;
            if (previousView) {
                [constraints addObject:[view sdal_matchDimension:dimension toDimension:dimension ofView:previousView]];
            }
            previousView = view;
        }
    }
    return constraints;
}

/**
 Sets the given dimension of all the views in this array to a given size.
 Note: This array must contain at least 1 view.
 
 @param dimension The dimension of each of the subviews to set.
 @param size The size to set the given dimension of each subview to.
 @return An array of constraints added.
 */
- (NSArray *)sdal_setViewsDimension:(SDALDimension)dimension toSize:(CGFloat)size
{
    NSAssert([self al_containsMinimumNumberOfViews:1], @"This array must contain at least 1 view.");
    NSMutableArray *constraints = [NSMutableArray new];
    for (id object in self) {
        if ([object isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)object;
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [constraints addObject:[view sdal_setDimension:dimension toSize:size]];
        }
    }
    return constraints;
}


#pragma mark Distribute Multiple Views

/**
 Distributes the views in this array equally along the selected axis in their superview.
 Views will be the same size (variable) in the dimension along the axis and will have spacing (fixed) between them,
 including from the first and last views to their superview.
 
 @param axis The axis along which to distribute the subviews.
 @param spacing The fixed amount of spacing between each subview, before the first subview and after the last subview.
 @param alignment The way in which the subviews will be aligned.
 @return An array of constraints added.
 */
- (NSArray *)sdal_distributeViewsAlongAxis:(SDALAxis)axis withFixedSpacing:(CGFloat)spacing alignment:(NSLayoutFormatOptions)alignment
{
    return [self sdal_distributeViewsAlongAxis:axis withFixedSpacing:spacing insetSpacing:YES alignment:alignment];
}

/**
 Distributes the views in this array equally along the selected axis in their superview.
 Views will be the same size (variable) in the dimension along the axis and will have spacing (fixed) between them.
 The first and last views can optionally be inset from their superview by the same amount of spacing as between views.
 
 @param axis The axis along which to distribute the subviews.
 @param spacing The fixed amount of spacing between each subview.
 @param shouldSpaceInsets Whether the first and last views should be equally inset from their superview.
 @param alignment The way in which the subviews will be aligned.
 @return An array of constraints added.
 */
- (NSArray *)sdal_distributeViewsAlongAxis:(SDALAxis)axis withFixedSpacing:(CGFloat)spacing insetSpacing:(BOOL)shouldSpaceInsets alignment:(NSLayoutFormatOptions)alignment
{
    return [self sdal_distributeViewsAlongAxis:axis withFixedSpacing:spacing insetSpacing:shouldSpaceInsets matchedSizes:YES alignment:alignment];
}

/**
 Distributes the views in this array equally along the selected axis in their superview.
 Views will have fixed spacing between them, and can optionally be constrained to the same size in the dimension along the axis.
 The first and last views can optionally be inset from their superview by the same amount of spacing as between views.
 
 @param axis The axis along which to distribute the subviews.
 @param spacing The fixed amount of spacing between each subview.
 @param shouldSpaceInsets Whether the first and last views should be equally inset from their superview.
 @param shouldMatchSizes Whether all views will be constrained to be the same size in the dimension along the axis.
                         NOTE: All views must specify an intrinsic content size if passing NO, otherwise the layout will be ambiguous!
 @param alignment The way in which the subviews will be aligned.
 @return An array of constraints added.
 */
- (NSArray *)sdal_distributeViewsAlongAxis:(SDALAxis)axis withFixedSpacing:(CGFloat)spacing insetSpacing:(BOOL)shouldSpaceInsets matchedSizes:(BOOL)shouldMatchSizes alignment:(NSLayoutFormatOptions)alignment
{
    NSAssert([self al_containsMinimumNumberOfViews:2], @"This array must contain at least 2 views to distribute.");
    SDALDimension matchedDimension;
    SDALEdge firstEdge, lastEdge;
    switch (axis) {
        case SDALAxisHorizontal:
        case SDALAxisBaseline:
            matchedDimension = SDALDimensionWidth;
            firstEdge = SDALEdgeLeading;
            lastEdge = SDALEdgeTrailing;
            break;
        case SDALAxisVertical:
            matchedDimension = SDALDimensionHeight;
            firstEdge = SDALEdgeTop;
            lastEdge = SDALEdgeBottom;
            break;
        default:
            NSAssert(nil, @"Not a valid SDALAxis.");
            return nil;
    }
    CGFloat leadingSpacing = shouldSpaceInsets ? spacing : 0.0;
    CGFloat trailingSpacing = shouldSpaceInsets ? spacing : 0.0;
    
    NSMutableArray *constraints = [NSMutableArray new];
    UIView *previousView = nil;
    for (id object in self) {
        if ([object isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)object;
            view.translatesAutoresizingMaskIntoConstraints = NO;
            if (previousView) {
                // Second, Third, ... View
                [constraints addObject:[view sdal_pinEdge:firstEdge toEdge:lastEdge ofView:previousView withOffset:spacing]];
                if (shouldMatchSizes) {
                    [constraints addObject:[view sdal_matchDimension:matchedDimension toDimension:matchedDimension ofView:previousView]];
                }
                [constraints addObject:[view al_alignToView:previousView withOption:alignment forAxis:axis]];
            }
            else {
                // First view
                [constraints addObject:[view sdal_pinEdgeToSuperviewEdge:firstEdge withInset:leadingSpacing]];
            }
            previousView = view;
        }
    }
    if (previousView) {
        // Last View
        [constraints addObject:[previousView sdal_pinEdgeToSuperviewEdge:lastEdge withInset:trailingSpacing]];
    }
    return constraints;
}

/**
 Distributes the views in this array equally along the selected axis in their superview.
 Views will be the same size (fixed) in the dimension along the axis and will have spacing (variable) between them,
 including from the first and last views to their superview.
 
 @param axis The axis along which to distribute the subviews.
 @param size The fixed size of each subview in the dimension along the given axis.
 @param alignment The way in which the subviews will be aligned.
 @return An array of constraints added.
 */
- (NSArray *)sdal_distributeViewsAlongAxis:(SDALAxis)axis withFixedSize:(CGFloat)size alignment:(NSLayoutFormatOptions)alignment
{
    return [self sdal_distributeViewsAlongAxis:axis withFixedSize:size insetSpacing:YES alignment:alignment];
}

/**
 Distributes the views in this array equally along the selected axis in their superview.
 Views will be the same size (fixed) in the dimension along the axis and will have spacing (variable) between them.
 The first and last views can optionally be inset from their superview by the same amount of spacing as between views.
 
 @param axis The axis along which to distribute the subviews.
 @param size The fixed size of each subview in the dimension along the given axis.
 @param shouldSpaceInsets Whether the first and last views should be equally inset from their superview.
 @param alignment The way in which the subviews will be aligned.
 @return An array of constraints added.
 */
- (NSArray *)sdal_distributeViewsAlongAxis:(SDALAxis)axis withFixedSize:(CGFloat)size insetSpacing:(BOOL)shouldSpaceInsets alignment:(NSLayoutFormatOptions)alignment
{
    NSAssert([self al_containsMinimumNumberOfViews:2], @"This array must contain at least 2 views to distribute.");
    SDALDimension fixedDimension;
    NSLayoutAttribute attribute;
    switch (axis) {
        case SDALAxisHorizontal:
        case SDALAxisBaseline:
            fixedDimension = SDALDimensionWidth;
            attribute = NSLayoutAttributeCenterX;
            break;
        case SDALAxisVertical:
            fixedDimension = SDALDimensionHeight;
            attribute = NSLayoutAttributeCenterY;
            break;
        default:
            NSAssert(nil, @"Not a valid SDALAxis.");
            return nil;
    }
    BOOL isRightToLeftLanguage = [NSLocale characterDirectionForLanguage:[[NSBundle mainBundle] preferredLocalizations][0]] == NSLocaleLanguageDirectionRightToLeft;
    BOOL shouldFlipOrder = isRightToLeftLanguage && (axis != SDALAxisVertical); // imitate the effect of leading/trailing when distributing horizontally
    
    NSMutableArray *constraints = [NSMutableArray new];
    NSArray *views = [self al_copyViewsOnly];
    NSUInteger numberOfViews = [views count];
    UIView *commonSuperview = [views al_commonSuperviewOfViews];
    UIView *previousView = nil;
    for (NSUInteger i = 0; i < numberOfViews; i++) {
        UIView *view = shouldFlipOrder ? views[numberOfViews - i - 1] : views[i];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [constraints addObject:[view sdal_setDimension:fixedDimension toSize:size]];
        CGFloat multiplier, constant;
        if (shouldSpaceInsets) {
            multiplier = (i * 2.0 + 2.0) / (numberOfViews + 1.0);
            constant = (multiplier - 1.0) * size / 2.0;
        } else {
            multiplier = (i * 2.0) / (numberOfViews - 1.0);
            constant = (-multiplier + 1.0) * size / 2.0;
        }
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:attribute relatedBy:NSLayoutRelationEqual toItem:commonSuperview attribute:attribute multiplier:multiplier constant:constant];
        [commonSuperview al_addConstraintUsingGlobalPriority:constraint];
        [constraints addObject:constraint];
        if (previousView) {
            [constraints addObject:[view al_alignToView:previousView withOption:alignment forAxis:axis]];
        }
        previousView = view;
    }
    return constraints;
}

#pragma mark Internal Helper Methods

/**
 Returns the common superview for the views in this array.
 Raises an exception if the views in this array do not share a common superview.
 
 @return The common superview for the views in this array.
 */
- (UIView *)al_commonSuperviewOfViews
{
    UIView *commonSuperview = nil;
    UIView *previousView = nil;
    for (id object in self) {
        if ([object isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)object;
            if (previousView) {
                commonSuperview = [view al_commonSuperviewWithView:commonSuperview];
            } else {
                commonSuperview = view;
            }
            previousView = view;
        }
    }
    NSAssert(commonSuperview, @"Can't constrain views that do not share a common superview. Make sure that all the views in this array have been added into the same view hierarchy.");
    return commonSuperview;
}

/**
 Determines whether this array contains a minimum number of views.
 
 @param minimumNumberOfViews The minimum number of views to check for.
 @return YES if this array contains at least the minimum number of views, NO otherwise.
 */
- (BOOL)al_containsMinimumNumberOfViews:(NSUInteger)minimumNumberOfViews
{
    NSUInteger numberOfViews = 0;
    for (id object in self) {
        if ([object isKindOfClass:[UIView class]]) {
            numberOfViews++;
            if (numberOfViews >= minimumNumberOfViews) {
                return YES;
            }
        }
    }
    return numberOfViews >= minimumNumberOfViews;
}

/**
 Creates a copy of this array containing only the view objects in it.
 
 @return A new array containing only the views that are in this array.
 */
- (NSArray *)al_copyViewsOnly
{
    NSMutableArray *viewsOnlyArray = [NSMutableArray arrayWithCapacity:[self count]];
    for (id object in self) {
        if ([object isKindOfClass:[UIView class]]) {
            [viewsOnlyArray addObject:object];
        }
    }
    return viewsOnlyArray;
}

@end
