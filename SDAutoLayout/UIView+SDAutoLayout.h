//  UIView+SDAutoLayoutDefines.h
//
//  Created by Sam Grover on 10/01/2014.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//
//  Based on:
//
//
//  ALView+PureLayout.h
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

#import "SDAutoLayoutDefines.h"


#pragma mark - UIView+SDAutoLayout

/**
 A category on UIView/NSView that provides a simple yet powerful interface for creating Auto Layout constraints.
 */
@interface UIView (SDAutoLayout)


#pragma mark Factory & Initializer Methods

/** Creates and returns a new view that does not convert the autoresizing mask into constraints. */
+ (instancetype)newSDAutoLayoutView;

/** Initializes and returns a new view that does not convert the autoresizing mask into constraints. */
- (instancetype)initForSDAutoLayout;


#pragma mark Set Constraint Priority

/** Sets the constraint priority to the given value for all constraints created using the SDAutoLayout API within the given constraints block.
    NOTE: This method will have no effect (and will NOT set the priority) on constraints created or added using the SDK directly within the block! */
+ (void)sdal_setPriority:(UILayoutPriority)priority forConstraints:(SDALConstraintsBlock)block;


#pragma mark Remove Constraints

/** Removes the given constraint from the view it has been added to. */
+ (void)sdal_removeConstraint:(NSLayoutConstraint *)constraint;

/** Removes the given constraints from the views they have been added to. */
+ (void)sdal_removeConstraints:(NSArray *)constraints;

/** Removes all explicit constraints that affect the view.
    WARNING: Apple's constraint solver is not optimized for large-scale constraint removal; you may encounter major performance issues after using this method.
    NOTE: This method preserves implicit constraints, such as intrinsic content size constraints, which you usually do not want to remove. */
- (void)sdal_removeConstraintsAffectingView;

/** Removes all constraints that affect the view, optionally including implicit constraints.
    WARNING: Apple's constraint solver is not optimized for large-scale constraint removal; you may encounter major performance issues after using this method.
    NOTE: Implicit constraints are auto-generated lower priority constraints, and you usually do not want to remove these. */
- (void)sdal_removeConstraintsAffectingViewIncludingImplicitConstraints:(BOOL)shouldRemoveImplicitConstraints;

/** Recursively removes all explicit constraints that affect the view and its subviews.
    WARNING: Apple's constraint solver is not optimized for large-scale constraint removal; you may encounter major performance issues after using this method.
    NOTE: This method preserves implicit constraints, such as intrinsic content size constraints, which you usually do not want to remove. */
- (void)sdal_removeConstraintsAffectingViewAndSubviews;

/** Recursively removes all constraints from the view and its subviews, optionally including implicit constraints.
    WARNING: Apple's constraint solver is not optimized for large-scale constraint removal; you may encounter major performance issues after using this method.
    NOTE: Implicit constraints are auto-generated lower priority constraints, and you usually do not want to remove these. */
- (void)sdal_removeConstraintsAffectingViewAndSubviewsIncludingImplicitConstraints:(BOOL)shouldRemoveImplicitConstraints;


#pragma mark Center in Superview

/** Centers the view in its superview. */
- (NSArray *)sdal_centerInSuperview;

/** Aligns the view to the same axis of its superview. */
- (NSLayoutConstraint *)sdal_alignAxisToSuperviewAxis:(SDALAxis)axis;


#pragma mark Pin Edges to Superview

/** Pins the given edge of the view to the same edge of its superview. */
- (NSLayoutConstraint *)sdal_pinEdgeToSuperviewEdge:(SDALEdge)edge;

/** Pins the given edge of the view to the same edge of its superview with an inset. */
- (NSLayoutConstraint *)sdal_pinEdgeToSuperviewEdge:(SDALEdge)edge withInset:(CGFloat)inset;

/** Pins the given edge of the view to the same edge of its superview with an inset as a maximum or minimum. */
- (NSLayoutConstraint *)sdal_pinEdgeToSuperviewEdge:(SDALEdge)edge withInset:(CGFloat)inset relation:(NSLayoutRelation)relation;

/** Pins the edges of the view to the edges of its superview with the given edge insets. */
- (NSArray *)sdal_pinEdgesToSuperviewEdgesWithInsets:(UIEdgeInsets)insets;

/** Pins 3 of the 4 edges of the view to the edges of its superview with the given edge insets, excluding one edge. */
- (NSArray *)sdal_pinEdgesToSuperviewEdgesWithInsets:(UIEdgeInsets)insets excludingEdge:(SDALEdge)edge;


#pragma mark Pin Edges

/** Pins an edge of the view to a given edge of another view. */
- (NSLayoutConstraint *)sdal_pinEdge:(SDALEdge)edge toEdge:(SDALEdge)toEdge ofView:(UIView *)peerView;

/** Pins an edge of the view to a given edge of another view with an offset. */
- (NSLayoutConstraint *)sdal_pinEdge:(SDALEdge)edge toEdge:(SDALEdge)toEdge ofView:(UIView *)peerView withOffset:(CGFloat)offset;

/** Pins an edge of the view to a given edge of another view with an offset as a maximum or minimum. */
- (NSLayoutConstraint *)sdal_pinEdge:(SDALEdge)edge toEdge:(SDALEdge)toEdge ofView:(UIView *)peerView withOffset:(CGFloat)offset relation:(NSLayoutRelation)relation;


#pragma mark Align Axes

/** Aligns an axis of the view to the same axis of another view. */
- (NSLayoutConstraint *)sdal_alignAxis:(SDALAxis)axis toSameAxisOfView:(UIView *)peerView;

/** Aligns an axis of the view to the same axis of another view with an offset. */
- (NSLayoutConstraint *)sdal_alignAxis:(SDALAxis)axis toSameAxisOfView:(UIView *)peerView withOffset:(CGFloat)offset;


#pragma mark Match Dimensions

/** Matches a dimension of the view to a given dimension of another view. */
- (NSLayoutConstraint *)sdal_matchDimension:(SDALDimension)dimension toDimension:(SDALDimension)toDimension ofView:(UIView *)peerView;

/** Matches a dimension of the view to a given dimension of another view with an offset. */
- (NSLayoutConstraint *)sdal_matchDimension:(SDALDimension)dimension toDimension:(SDALDimension)toDimension ofView:(UIView *)peerView withOffset:(CGFloat)offset;

/** Matches a dimension of the view to a given dimension of another view with an offset as a maximum or minimum. */
- (NSLayoutConstraint *)sdal_matchDimension:(SDALDimension)dimension toDimension:(SDALDimension)toDimension ofView:(UIView *)peerView withOffset:(CGFloat)offset relation:(NSLayoutRelation)relation;

/** Matches a dimension of the view to a multiple of a given dimension of another view. */
- (NSLayoutConstraint *)sdal_matchDimension:(SDALDimension)dimension toDimension:(SDALDimension)toDimension ofView:(UIView *)peerView withMultiplier:(CGFloat)multiplier;

/** Matches a dimension of the view to a multiple of a given dimension of another view as a maximum or minimum. */
- (NSLayoutConstraint *)sdal_matchDimension:(SDALDimension)dimension toDimension:(SDALDimension)toDimension ofView:(UIView *)peerView withMultiplier:(CGFloat)multiplier relation:(NSLayoutRelation)relation;


#pragma mark Set Dimensions

/** Sets the view to a specific size. */
- (NSArray *)sdal_setDimensionsToSize:(CGSize)size;

/** Sets the given dimension of the view to a specific size. */
- (NSLayoutConstraint *)sdal_setDimension:(SDALDimension)dimension toSize:(CGFloat)size;

/** Sets the given dimension of the view to a specific size as a maximum or minimum. */
- (NSLayoutConstraint *)sdal_setDimension:(SDALDimension)dimension toSize:(CGFloat)size relation:(NSLayoutRelation)relation;


#pragma mark Set Content Compression Resistance & Hugging

/** Sets the priority of content compression resistance for an axis.
    NOTE: This method must only be called from within the block passed into the method +[autoSetPriority:forConstraints:] */
- (void)sdal_setContentCompressionResistancePriorityForAxis:(SDALAxis)axis;

/** Sets the priority of content hugging for an axis.
    NOTE: This method must only be called from within the block passed into the method +[autoSetPriority:forConstraints:] */
- (void)sdal_setContentHuggingPriorityForAxis:(SDALAxis)axis;


#pragma mark Constrain Any Attributes

/** Constrains an attribute (any SDALEdge, SDALAxis, or SDALDimension) of the view to a given attribute of another view. */
- (NSLayoutConstraint *)sdal_constrainAttribute:(NSInteger)attribute toAttribute:(NSInteger)toAttribute ofView:(UIView *)peerView;

/** Constrains an attribute (any SDALEdge, SDALAxis, or SDALDimension) of the view to a given attribute of another view with an offset. */
- (NSLayoutConstraint *)sdal_constrainAttribute:(NSInteger)attribute toAttribute:(NSInteger)toAttribute ofView:(UIView *)peerView withOffset:(CGFloat)offset;

/** Constrains an attribute (any SDALEdge, SDALAxis, or SDALDimension) of the view to a given attribute of another view with an offset as a maximum or minimum. */
- (NSLayoutConstraint *)sdal_constrainAttribute:(NSInteger)attribute toAttribute:(NSInteger)toAttribute ofView:(UIView *)peerView withOffset:(CGFloat)offset relation:(NSLayoutRelation)relation;

/** Constrains an attribute (any SDALEdge, SDALAxis, or SDALDimension) of the view to a given attribute of another view with a multiplier. */
- (NSLayoutConstraint *)sdal_constrainAttribute:(NSInteger)attribute toAttribute:(NSInteger)toAttribute ofView:(UIView *)peerView withMultiplier:(CGFloat)multiplier;

/** Constrains an attribute (any SDALEdge, SDALAxis, or SDALDimension) of the view to a given attribute of another view with a multiplier as a maximum or minimum. */
- (NSLayoutConstraint *)sdal_constrainAttribute:(NSInteger)attribute toAttribute:(NSInteger)toAttribute ofView:(UIView *)peerView withMultiplier:(CGFloat)multiplier relation:(NSLayoutRelation)relation;


#pragma mark Pin to Layout Guides (iOS only)

/** Pins the top edge of the view to the top layout guide of the given view controller with an inset. */
- (NSLayoutConstraint *)sdal_pinToTopLayoutGuideOfViewController:(UIViewController *)viewController withInset:(CGFloat)inset;

/** Pins the bottom edge of the view to the bottom layout guide of the given view controller with an inset. */
- (NSLayoutConstraint *)sdal_pinToBottomLayoutGuideOfViewController:(UIViewController *)viewController withInset:(CGFloat)inset;

@end
