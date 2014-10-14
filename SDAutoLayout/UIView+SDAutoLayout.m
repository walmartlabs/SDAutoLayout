//  UIView+SDAutoLayout.m
//
//  Created by Sam Grover on 10/01/2014.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//
//  Based on:
//
//  ALView+PureLayout.m
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

#import "UIView+SDAutoLayout.h"
#import "NSLayoutConstraint+SDAutoLayout.h"


#pragma mark - UIView+SDAutoLayout

@implementation UIView (SDAutoLayout)


#pragma mark Factory & Initializer Methods

/** 
 Creates and returns a new view that does not convert the autoresizing mask into constraints.
 */
+ (instancetype)newSDAutoLayoutView
{
    UIView *view = [self new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

/**
 Initializes and returns a new view that does not convert the autoresizing mask into constraints.
 */
- (instancetype)initForSDAutoLayout
{
    self = [self init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}


#pragma mark Set Constraint Priority

/** 
 A global variable that determines the priority of all constraints created and added by this category.
 Defaults to Required, will only be a different value while executing a constraints block passed into the
 +[autoSetPriority:forConstraints:] method (as that method will reset the value back to Required
 before returning).
 NOTE: Access to this variable is not synchronized (and should only be done on the main thread).
 */
static UILayoutPriority _sdal_globalConstraintPriority = UILayoutPriorityRequired;

/**
 A global variable that is set to YES while the constraints block passed in to the
 +[autoSetPriority:forConstraints:] method is executing.
 NOTE: Access to this variable is not synchronized (and should only be done on the main thread).
 */
static BOOL _al_isExecutingConstraintsBlock = NO;

/**
 Sets the constraint priority to the given value for all constraints created using the SDAutoLayout
 API within the given constraints block.
 
 NOTE: This method will have no effect (and will NOT set the priority) on constraints created or added 
 using the SDK directly within the block!
 
 @param priority The layout priority to be set on all constraints in the constraints block.
 @param block A block of method calls to the SDAutoLayout API that create and add constraints.
 */
+ (void)sdal_setPriority:(UILayoutPriority)priority forConstraints:(SDALConstraintsBlock)block
{
    NSAssert(block, @"The constraints block cannot be nil.");
    if (block) {
        _sdal_globalConstraintPriority = priority;
        _al_isExecutingConstraintsBlock = YES;
        block();
        _al_isExecutingConstraintsBlock = NO;
        _sdal_globalConstraintPriority = UILayoutPriorityRequired;
    }
}


#pragma mark Remove Constraints

/**
 Removes the given constraint from the view it has been added to.
 
 @param constraint The constraint to remove.
 */
+ (void)sdal_removeConstraint:(NSLayoutConstraint *)constraint
{
    if (constraint.secondItem) {
        UIView *commonSuperview = [constraint.firstItem al_commonSuperviewWithView:constraint.secondItem];
        while (commonSuperview) {
            if ([commonSuperview.constraints containsObject:constraint]) {
                [commonSuperview removeConstraint:constraint];
                return;
            }
            commonSuperview = commonSuperview.superview;
        }
    }
    else {
        [constraint.firstItem removeConstraint:constraint];
        return;
    }
    NSAssert(nil, @"Failed to remove constraint: %@", constraint);
}

/**
 Removes the given constraints from the views they have been added to.
 
 @param constraints The constraints to remove.
 */
+ (void)sdal_removeConstraints:(NSArray *)constraints
{
    for (id object in constraints) {
        if ([object isKindOfClass:[NSLayoutConstraint class]]) {
            [self sdal_removeConstraint:((NSLayoutConstraint *)object)];
        } else {
            NSAssert(nil, @"All constraints to remove must be instances of NSLayoutConstraint.");
        }
    }
}

/**
 Removes all explicit constraints that affect the view.
 WARNING: Apple's constraint solver is not optimized for large-scale constraint removal; you may encounter major performance issues after using this method.
          It is not recommended to use this method to "reset" a view for reuse in a different way with new constraints. Create a new view instead.
 NOTE: This method preserves implicit constraints, such as intrinsic content size constraints, which you usually do not want to remove.
 */
- (void)sdal_removeConstraintsAffectingView
{
    [self sdal_removeConstraintsAffectingViewIncludingImplicitConstraints:NO];
}

/**
 Removes all constraints that affect the view, optionally including implicit constraints.
 WARNING: Apple's constraint solver is not optimized for large-scale constraint removal; you may encounter major performance issues after using this method.
          It is not recommended to use this method to "reset" a view for reuse in a different way with new constraints. Create a new view instead.
 NOTE: Implicit constraints are auto-generated lower priority constraints (such as those that attempt to keep a view at
 its intrinsic content size by hugging its content & resisting compression), and you usually do not want to remove these.
 
 @param shouldRemoveImplicitConstraints Whether implicit constraints should be removed or skipped.
 */
- (void)sdal_removeConstraintsAffectingViewIncludingImplicitConstraints:(BOOL)shouldRemoveImplicitConstraints
{
    NSMutableArray *constraintsToRemove = [NSMutableArray new];
    UIView *startView = self;
    do {
        for (NSLayoutConstraint *constraint in startView.constraints) {
            BOOL isImplicitConstraint = [NSStringFromClass([constraint class]) isEqualToString:@"NSContentSizeLayoutConstraint"];
            if (shouldRemoveImplicitConstraints || !isImplicitConstraint) {
                if (constraint.firstItem == self || constraint.secondItem == self) {
                    [constraintsToRemove addObject:constraint];
                }
            }
        }
        startView = startView.superview;
    } while (startView);
    [UIView sdal_removeConstraints:constraintsToRemove];
}

/**
 Recursively removes all explicit constraints that affect the view and its subviews.
 WARNING: Apple's constraint solver is not optimized for large-scale constraint removal; you may encounter major performance issues after using this method.
          It is not recommended to use this method to "reset" views for reuse in a different way with new constraints. Create a new view instead.
 NOTE: This method preserves implicit constraints, such as intrinsic content size constraints, which you usually do not want to remove.
 */
- (void)sdal_removeConstraintsAffectingViewAndSubviews
{
    [self sdal_removeConstraintsAffectingViewAndSubviewsIncludingImplicitConstraints:NO];
}

/** 
 Recursively removes all constraints that affect the view and its subviews, optionally including implicit constraints.
 WARNING: Apple's constraint solver is not optimized for large-scale constraint removal; you may encounter major performance issues after using this method.
          It is not recommended to use this method to "reset" views for reuse in a different way with new constraints. Create a new view instead.
 NOTE: Implicit constraints are auto-generated lower priority constraints (such as those that attempt to keep a view at
 its intrinsic content size by hugging its content & resisting compression), and you usually do not want to remove these.
 
 @param shouldRemoveImplicitConstraints Whether implicit constraints should be removed or skipped.
 */
- (void)sdal_removeConstraintsAffectingViewAndSubviewsIncludingImplicitConstraints:(BOOL)shouldRemoveImplicitConstraints
{
    [self sdal_removeConstraintsAffectingViewIncludingImplicitConstraints:shouldRemoveImplicitConstraints];
    for (UIView *subview in self.subviews) {
        [subview sdal_removeConstraintsAffectingViewAndSubviewsIncludingImplicitConstraints:shouldRemoveImplicitConstraints];
    }
}


#pragma mark Center in Superview

/**
 Centers the view in its superview.
 
 @return An array of constraints added.
 */
- (NSArray *)sdal_centerInSuperview
{
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObject:[self sdal_alignAxisToSuperviewAxis:SDALAxisHorizontal]];
    [constraints addObject:[self sdal_alignAxisToSuperviewAxis:SDALAxisVertical]];
    return constraints;
}

/**
 Aligns the view to the same axis of its superview.
 
 @param axis The axis of this view and of its superview to align.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_alignAxisToSuperviewAxis:(SDALAxis)axis
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *superview = self.superview;
    NSAssert(superview, @"View's superview must not be nil.\nView: %@", self);
    NSLayoutAttribute attribute = [UIView al_attributeForAxis:axis];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:NSLayoutRelationEqual toItem:superview attribute:attribute multiplier:1.0 constant:0.0];
    [constraint sdal_install];
    return constraint;
}


#pragma mark Pin Edges to Superview

/**
 Pins the given edge of the view to the same edge of its superview.
 
 @param edge The edge of this view and its superview to pin.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_pinEdgeToSuperviewEdge:(SDALEdge)edge
{
    return [self sdal_pinEdgeToSuperviewEdge:edge withInset:0.0];
}

/**
 Pins the given edge of the view to the same edge of its superview with an inset.
 
 @param edge The edge of this view and its superview to pin.
 @param inset The amount to inset this view's edge from the superview's edge.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_pinEdgeToSuperviewEdge:(SDALEdge)edge withInset:(CGFloat)inset
{
    return [self sdal_pinEdgeToSuperviewEdge:edge withInset:inset relation:NSLayoutRelationEqual];
}

/**
 Pins the given edge of the view to the same edge of its superview with an inset as a maximum or minimum.
 
 @param edge The edge of this view and its superview to pin.
 @param inset The amount to inset this view's edge from the superview's edge.
 @param relation Whether the inset should be at least, at most, or exactly equal to the given value.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_pinEdgeToSuperviewEdge:(SDALEdge)edge withInset:(CGFloat)inset relation:(NSLayoutRelation)relation
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *superview = self.superview;
    NSAssert(superview, @"View's superview must not be nil.\nView: %@", self);
    if (edge == SDALEdgeBottom || edge == SDALEdgeRight || edge == SDALEdgeTrailing) {
        // The bottom, right, and trailing insets (and relations, if an inequality) are inverted to become offsets
        inset = -inset;
        if (relation == NSLayoutRelationLessThanOrEqual) {
            relation = NSLayoutRelationGreaterThanOrEqual;
        } else if (relation == NSLayoutRelationGreaterThanOrEqual) {
            relation = NSLayoutRelationLessThanOrEqual;
        }
    }
    return [self sdal_pinEdge:edge toEdge:edge ofView:superview withOffset:inset relation:relation];
}

/**
 Pins the edges of the view to the edges of its superview with the given edge insets.
 The insets.left corresponds to a leading edge constraint, and insets.right corresponds to a trailing edge constraint.
 
 @param insets The insets for this view's edges from its superview's edges.
 @return An array of constraints added.
 */
- (NSArray *)sdal_pinEdgesToSuperviewEdgesWithInsets:(UIEdgeInsets)insets
{
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObject:[self sdal_pinEdgeToSuperviewEdge:SDALEdgeTop withInset:insets.top]];
    [constraints addObject:[self sdal_pinEdgeToSuperviewEdge:SDALEdgeLeading withInset:insets.left]];
    [constraints addObject:[self sdal_pinEdgeToSuperviewEdge:SDALEdgeBottom withInset:insets.bottom]];
    [constraints addObject:[self sdal_pinEdgeToSuperviewEdge:SDALEdgeTrailing withInset:insets.right]];
    return constraints;
}

/**
 Pins 3 of the 4 edges of the view to the edges of its superview with the given edge insets, excluding one edge.
 The insets.left corresponds to a leading edge constraint, and insets.right corresponds to a trailing edge constraint.
 
 @param insets The insets for this view's edges from its superview's edges. The inset corresponding to the excluded edge
               will be ignored.
 @param edge The edge of this view to exclude in pinning to its superview; this method will not apply any constraint to it.
 @return An array of constraints added.
 */
- (NSArray *)sdal_pinEdgesToSuperviewEdgesWithInsets:(UIEdgeInsets)insets excludingEdge:(SDALEdge)edge
{
    NSMutableArray *constraints = [NSMutableArray new];
    if (edge != SDALEdgeTop) {
        [constraints addObject:[self sdal_pinEdgeToSuperviewEdge:SDALEdgeTop withInset:insets.top]];
    }
    if (edge != SDALEdgeLeading && edge != SDALEdgeLeft) {
        [constraints addObject:[self sdal_pinEdgeToSuperviewEdge:SDALEdgeLeading withInset:insets.left]];
    }
    if (edge != SDALEdgeBottom) {
        [constraints addObject:[self sdal_pinEdgeToSuperviewEdge:SDALEdgeBottom withInset:insets.bottom]];
    }
    if (edge != SDALEdgeTrailing && edge != SDALEdgeRight) {
        [constraints addObject:[self sdal_pinEdgeToSuperviewEdge:SDALEdgeTrailing withInset:insets.right]];
    }
    return constraints;
}


#pragma mark Pin Edges

/**
 Pins an edge of the view to a given edge of another view.
 
 @param edge The edge of this view to pin.
 @param toEdge The edge of the peer view to pin to.
 @param peerView The peer view to pin to. Must be in the same view hierarchy as this view.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_pinEdge:(SDALEdge)edge toEdge:(SDALEdge)toEdge ofView:(UIView *)peerView
{
    return [self sdal_pinEdge:edge toEdge:toEdge ofView:peerView withOffset:0.0];
}

/**
 Pins an edge of the view to a given edge of another view with an offset.
 
 @param edge The edge of this view to pin.
 @param toEdge The edge of the peer view to pin to.
 @param peerView The peer view to pin to. Must be in the same view hierarchy as this view.
 @param offset The offset between the edge of this view and the edge of the peer view.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_pinEdge:(SDALEdge)edge toEdge:(SDALEdge)toEdge ofView:(UIView *)peerView withOffset:(CGFloat)offset
{
    return [self sdal_pinEdge:edge toEdge:toEdge ofView:peerView withOffset:offset relation:NSLayoutRelationEqual];
}

/**
 Pins an edge of the view to a given edge of another view with an offset as a maximum or minimum.
 
 @param edge The edge of this view to pin.
 @param toEdge The edge of the peer view to pin to.
 @param peerView The peer view to pin to. Must be in the same view hierarchy as this view.
 @param offset The offset between the edge of this view and the edge of the peer view.
 @param relation Whether the offset should be at least, at most, or exactly equal to the given value.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_pinEdge:(SDALEdge)edge toEdge:(SDALEdge)toEdge ofView:(UIView *)peerView withOffset:(CGFloat)offset relation:(NSLayoutRelation)relation
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutAttribute attribute = [UIView al_attributeForEdge:edge];
    NSLayoutAttribute toAttribute = [UIView al_attributeForEdge:toEdge];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:peerView attribute:toAttribute multiplier:1.0 constant:offset];
    [constraint sdal_install];
    return constraint;
}


#pragma mark Align Axes

/**
 Aligns an axis of the view to the same axis of another view.
 
 @param axis The axis of this view and the peer view to align.
 @param peerView The peer view to align to. Must be in the same view hierarchy as this view.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_alignAxis:(SDALAxis)axis toSameAxisOfView:(UIView *)peerView
{
    return [self sdal_alignAxis:axis toSameAxisOfView:peerView withOffset:0.0];
}

/**
 Aligns an axis of the view to the same axis of another view with an offset.
 
 @param axis The axis of this view and the peer view to align.
 @param peerView The peer view to align to. Must be in the same view hierarchy as this view.
 @param offset The offset between the axis of this view and the axis of the peer view.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_alignAxis:(SDALAxis)axis toSameAxisOfView:(UIView *)peerView withOffset:(CGFloat)offset
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutAttribute attribute = [UIView al_attributeForAxis:axis];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:NSLayoutRelationEqual toItem:peerView attribute:attribute multiplier:1.0 constant:offset];
    [constraint sdal_install];
    return constraint;
}


#pragma mark Match Dimensions

/**
 Matches a dimension of the view to a given dimension of another view.
 
 @param dimension The dimension of this view to pin.
 @param toDimension The dimension of the peer view to pin to.
 @param peerView The peer view to match to. Must be in the same view hierarchy as this view.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_matchDimension:(SDALDimension)dimension toDimension:(SDALDimension)toDimension ofView:(UIView *)peerView
{
    return [self sdal_matchDimension:dimension toDimension:toDimension ofView:peerView withOffset:0.0];
}

/**
 Matches a dimension of the view to a given dimension of another view with an offset.
 
 @param dimension The dimension of this view to pin.
 @param toDimension The dimension of the peer view to pin to.
 @param peerView The peer view to match to. Must be in the same view hierarchy as this view.
 @param offset The offset between the dimension of this view and the dimension of the peer view.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_matchDimension:(SDALDimension)dimension toDimension:(SDALDimension)toDimension ofView:(UIView *)peerView withOffset:(CGFloat)offset
{
    return [self sdal_matchDimension:dimension toDimension:toDimension ofView:peerView withOffset:offset relation:NSLayoutRelationEqual];
}

/**
 Matches a dimension of the view to a given dimension of another view with an offset as a maximum or minimum.
 
 @param dimension The dimension of this view to pin.
 @param toDimension The dimension of the peer view to pin to.
 @param peerView The peer view to match to. Must be in the same view hierarchy as this view.
 @param offset The offset between the dimension of this view and the dimension of the peer view.
 @param relation Whether the offset should be at least, at most, or exactly equal to the given value.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_matchDimension:(SDALDimension)dimension toDimension:(SDALDimension)toDimension ofView:(UIView *)peerView withOffset:(CGFloat)offset relation:(NSLayoutRelation)relation
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutAttribute attribute = [UIView al_attributeForDimension:dimension];
    NSLayoutAttribute toAttribute = [UIView al_attributeForDimension:toDimension];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:peerView attribute:toAttribute multiplier:1.0 constant:offset];
    [constraint sdal_install];
    return constraint;
}

/**
 Matches a dimension of the view to a multiple of a given dimension of another view.
 
 @param dimension The dimension of this view to pin.
 @param toDimension The dimension of the peer view to pin to.
 @param peerView The peer view to match to. Must be in the same view hierarchy as this view.
 @param multiplier The multiple of the peer view's given dimension that this view's given dimension should be.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_matchDimension:(SDALDimension)dimension toDimension:(SDALDimension)toDimension ofView:(UIView *)peerView withMultiplier:(CGFloat)multiplier
{
    return [self sdal_matchDimension:dimension toDimension:toDimension ofView:peerView withMultiplier:multiplier relation:NSLayoutRelationEqual];
}

/**
 Matches a dimension of the view to a multiple of a given dimension of another view as a maximum or minimum.
 
 @param dimension The dimension of this view to pin.
 @param toDimension The dimension of the peer view to pin to.
 @param peerView The peer view to match to. Must be in the same view hierarchy as this view.
 @param multiplier The multiple of the peer view's given dimension that this view's given dimension should be.
 @param relation Whether the multiple should be at least, at most, or exactly equal to the given value.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_matchDimension:(SDALDimension)dimension toDimension:(SDALDimension)toDimension ofView:(UIView *)peerView withMultiplier:(CGFloat)multiplier relation:(NSLayoutRelation)relation
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutAttribute attribute = [UIView al_attributeForDimension:dimension];
    NSLayoutAttribute toAttribute = [UIView al_attributeForDimension:toDimension];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:peerView attribute:toAttribute multiplier:multiplier constant:0.0];
    [constraint sdal_install];
    return constraint;
}


#pragma mark Set Dimensions

/**
 Sets the view to a specific size.
 
 @param size The size to set this view's dimensions to.
 @return An array of constraints added.
 */
- (NSArray *)sdal_setDimensionsToSize:(CGSize)size
{
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObject:[self sdal_setDimension:SDALDimensionWidth toSize:size.width]];
    [constraints addObject:[self sdal_setDimension:SDALDimensionHeight toSize:size.height]];
    return constraints;
}

/**
 Sets the given dimension of the view to a specific size.
 
 @param dimension The dimension of this view to set.
 @param size The size to set the given dimension to.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_setDimension:(SDALDimension)dimension toSize:(CGFloat)size
{
    return [self sdal_setDimension:dimension toSize:size relation:NSLayoutRelationEqual];
}

/**
 Sets the given dimension of the view to a specific size as a maximum or minimum.
 
 @param dimension The dimension of this view to set.
 @param size The size to set the given dimension to.
 @param relation Whether the size should be at least, at most, or exactly equal to the given value.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_setDimension:(SDALDimension)dimension toSize:(CGFloat)size relation:(NSLayoutRelation)relation
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutAttribute attribute = [UIView al_attributeForDimension:dimension];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:size];
    [constraint sdal_install];
    return constraint;
}


#pragma mark Set Content Compression Resistance & Hugging

/**
 Sets the priority of content compression resistance for an axis.
 NOTE: This method must only be called from within the block passed into the method +[autoSetPriority:forConstraints:]
 
 @param axis The axis to set the content compression resistance priority for.
 */
- (void)sdal_setContentCompressionResistancePriorityForAxis:(SDALAxis)axis
{
    NSAssert(_al_isExecutingConstraintsBlock, @"%@ should only be called from within the block passed into the method +[autoSetPriority:forConstraints:]", NSStringFromSelector(_cmd));
    if (_al_isExecutingConstraintsBlock) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        UILayoutConstraintAxis constraintAxis = [UIView al_constraintAxisForAxis:axis];
        [self setContentCompressionResistancePriority:_sdal_globalConstraintPriority forAxis:constraintAxis];
    }
}

/**
 Sets the priority of content hugging for an axis.
 NOTE: This method must only be called from within the block passed into the method +[autoSetPriority:forConstraints:]
 
 @param axis The axis to set the content hugging priority for.
 */
- (void)sdal_setContentHuggingPriorityForAxis:(SDALAxis)axis
{
    NSAssert(_al_isExecutingConstraintsBlock, @"%@ should only be called from within the block passed into the method +[autoSetPriority:forConstraints:]", NSStringFromSelector(_cmd));
    if (_al_isExecutingConstraintsBlock) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        UILayoutConstraintAxis constraintAxis = [UIView al_constraintAxisForAxis:axis];
        [self setContentHuggingPriority:_sdal_globalConstraintPriority forAxis:constraintAxis];
    }
}


#pragma mark Constrain Any Attributes

/**
 Constrains an attribute (any SDALEdge, SDALAxis, or SDALDimension) of the view to a given attribute of another view.
 This method can be used to constrain different types of attributes across two views.
 
 @param SDALAttribute Any SDALEdge, SDALAxis, or SDALDimension of this view to constrain.
 @param toSDALAttribute Any SDALEdge, SDALAxis, or SDALDimension of the peer view to constrain to.
 @param peerView The peer view to constrain to. Must be in the same view hierarchy as this view.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_constrainAttribute:(NSInteger)SDALAttribute toAttribute:(NSInteger)toSDALAttribute ofView:(UIView *)peerView
{
    return [self sdal_constrainAttribute:SDALAttribute toAttribute:toSDALAttribute ofView:peerView withOffset:0.0];
}

/**
 Constrains an attribute (any SDALEdge, SDALAxis, or SDALDimension) of the view to a given attribute of another view with an offset.
 This method can be used to constrain different types of attributes across two views.
 
 @param SDALAttribute Any SDALEdge, SDALAxis, or SDALDimension of this view to constrain.
 @param toSDALAttribute Any SDALEdge, SDALAxis, or SDALDimension of the peer view to constrain to.
 @param peerView The peer view to constrain to. Must be in the same view hierarchy as this view.
 @param offset The offset between the attribute of this view and the attribute of the peer view.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_constrainAttribute:(NSInteger)SDALAttribute toAttribute:(NSInteger)toSDALAttribute ofView:(UIView *)peerView withOffset:(CGFloat)offset
{
    return [self sdal_constrainAttribute:SDALAttribute toAttribute:toSDALAttribute ofView:peerView withOffset:offset relation:NSLayoutRelationEqual];
}

/**
 Constrains an attribute (any SDALEdge, SDALAxis, or SDALDimension) of the view to a given attribute of another view with an offset as a maximum or minimum.
 This method can be used to constrain different types of attributes across two views.
 
 @param SDALAttribute Any SDALEdge, SDALAxis, or SDALDimension of this view to constrain.
 @param toSDALAttribute Any SDALEdge, SDALAxis, or SDALDimension of the peer view to constrain to.
 @param peerView The peer view to constrain to. Must be in the same view hierarchy as this view.
 @param offset The offset between the attribute of this view and the attribute of the peer view.
 @param relation Whether the offset should be at least, at most, or exactly equal to the given value.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_constrainAttribute:(NSInteger)SDALAttribute toAttribute:(NSInteger)toSDALAttribute ofView:(UIView *)peerView withOffset:(CGFloat)offset relation:(NSLayoutRelation)relation
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutAttribute attribute = [UIView al_attributeForSDALAttribute:SDALAttribute];
    NSLayoutAttribute toAttribute = [UIView al_attributeForSDALAttribute:toSDALAttribute];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:peerView attribute:toAttribute multiplier:1.0 constant:offset];
    [constraint sdal_install];
    return constraint;
}

/**
 Constrains an attribute (any SDALEdge, SDALAxis, or SDALDimension) of the view to a given attribute of another view with a multiplier.
 This method can be used to constrain different types of attributes across two views.
 
 @param SDALAttribute Any SDALEdge, SDALAxis, or SDALDimension of this view to constrain.
 @param toSDALAttribute Any SDALEdge, SDALAxis, or SDALDimension of the peer view to constrain to.
 @param peerView The peer view to constrain to. Must be in the same view hierarchy as this view.
 @param multiplier The multiplier between the attribute of this view and the attribute of the peer view.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_constrainAttribute:(NSInteger)SDALAttribute toAttribute:(NSInteger)toSDALAttribute ofView:(UIView *)peerView withMultiplier:(CGFloat)multiplier
{
    return [self sdal_constrainAttribute:SDALAttribute toAttribute:toSDALAttribute ofView:peerView withMultiplier:multiplier relation:NSLayoutRelationEqual];
}

/**
 Constrains an attribute (any SDALEdge, SDALAxis, or SDALDimension) of the view to a given attribute of another view with a multiplier as a maximum or minimum.
 This method can be used to constrain different types of attributes across two views.
 
 @param SDALAttribute Any SDALEdge, SDALAxis, or SDALDimension of this view to constrain.
 @param toSDALAttribute Any SDALEdge, SDALAxis, or SDALDimension of the peer view to constrain to.
 @param peerView The peer view to constrain to. Must be in the same view hierarchy as this view.
 @param multiplier The multiplier between the attribute of this view and the attribute of the peer view.
 @param relation Whether the multiplier should be at least, at most, or exactly equal to the given value.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_constrainAttribute:(NSInteger)SDALAttribute toAttribute:(NSInteger)toSDALAttribute ofView:(UIView *)peerView withMultiplier:(CGFloat)multiplier relation:(NSLayoutRelation)relation
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutAttribute attribute = [UIView al_attributeForSDALAttribute:SDALAttribute];
    NSLayoutAttribute toAttribute = [UIView al_attributeForSDALAttribute:toSDALAttribute];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:peerView attribute:toAttribute multiplier:multiplier constant:0.0];
    [constraint sdal_install];
    return constraint;
}


#pragma mark Pin to Layout Guides

/**
 Pins the top edge of the view to the top layout guide of the given view controller with an inset.
 For compatibility with iOS 6 (where layout guides do not exist), this method will simply pin the top edge of
 the view to the top edge of the given view controller's view with an inset.
 
 @param viewController The view controller whose topLayoutGuide should be used to pin to.
 @param inset The amount to inset this view's top edge from the layout guide.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_pinToTopLayoutGuideOfViewController:(UIViewController *)viewController withInset:(CGFloat)inset
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return [self sdal_pinEdge:SDALEdgeTop toEdge:SDALEdgeTop ofView:viewController.view withOffset:inset];
    } else {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:viewController.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:inset];
        [viewController.view al_addConstraintUsingGlobalPriority:constraint];
        return constraint;
    }
}

/**
 Pins the bottom edge of the view to the bottom layout guide of the given view controller with an inset.
 For compatibility with iOS 6 (where layout guides do not exist), this method will simply pin the bottom edge of
 the view to the bottom edge of the given view controller's view with an inset.
 
 @param viewController The view controller whose bottomLayoutGuide should be used to pin to.
 @param inset The amount to inset this view's bottom edge from the layout guide.
 @return The constraint added.
 */
- (NSLayoutConstraint *)sdal_pinToBottomLayoutGuideOfViewController:(UIViewController *)viewController withInset:(CGFloat)inset
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return [self sdal_pinEdge:SDALEdgeBottom toEdge:SDALEdgeBottom ofView:viewController.view withOffset:-inset];
    } else {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:viewController.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.0 constant:-inset];
        [viewController.view al_addConstraintUsingGlobalPriority:constraint];
        return constraint;
    }
}


#pragma mark Internal Helper Methods

/**
 Adds the given constraint to this view after setting the constraint's priority to the global constraint priority.
 
 This method is the only one that calls the SDK addConstraint: method directly; all other instances in this category
 should use this method to add constraints so that the global priority is correctly set on constraints.
 
 @param constraint The constraint to set the global priority on and then add to this view.
 */
- (void)al_addConstraintUsingGlobalPriority:(NSLayoutConstraint *)constraint
{
    constraint.priority = _sdal_globalConstraintPriority;
    [self addConstraint:constraint];
}

/**
 Returns the corresponding NSLayoutAttribute for the given SDALEdge.
 
 @return The layout attribute for the given edge.
 */
+ (NSLayoutAttribute)al_attributeForEdge:(SDALEdge)edge
{
    NSLayoutAttribute attribute = NSLayoutAttributeNotAnAttribute;
    switch (edge) {
        case SDALEdgeLeft:
            attribute = NSLayoutAttributeLeft;
            break;
        case SDALEdgeRight:
            attribute = NSLayoutAttributeRight;
            break;
        case SDALEdgeTop:
            attribute = NSLayoutAttributeTop;
            break;
        case SDALEdgeBottom:
            attribute = NSLayoutAttributeBottom;
            break;
        case SDALEdgeLeading:
            attribute = NSLayoutAttributeLeading;
            break;
        case SDALEdgeTrailing:
            attribute = NSLayoutAttributeTrailing;
            break;
        default:
            NSAssert(nil, @"Not a valid SDALEdge.");
            break;
    }
    return attribute;
}

/**
 Returns the corresponding NSLayoutAttribute for the given SDALAxis.
 
 @return The layout attribute for the given axis.
 */
+ (NSLayoutAttribute)al_attributeForAxis:(SDALAxis)axis
{
    NSLayoutAttribute attribute = NSLayoutAttributeNotAnAttribute;
    switch (axis) {
        case SDALAxisVertical:
            attribute = NSLayoutAttributeCenterX;
            break;
        case SDALAxisHorizontal:
            attribute = NSLayoutAttributeCenterY;
            break;
        case SDALAxisBaseline:
            attribute = NSLayoutAttributeBaseline;
            break;
        default:
            NSAssert(nil, @"Not a valid SDALAxis.");
            break;
    }
    return attribute;
}

/**
 Returns the corresponding NSLayoutAttribute for the given SDALDimension.
 
 @return The layout attribute for the given dimension.
 */
+ (NSLayoutAttribute)al_attributeForDimension:(SDALDimension)dimension
{
    NSLayoutAttribute attribute = NSLayoutAttributeNotAnAttribute;
    switch (dimension) {
        case SDALDimensionWidth:
            attribute = NSLayoutAttributeWidth;
            break;
        case SDALDimensionHeight:
            attribute = NSLayoutAttributeHeight;
            break;
        default:
            NSAssert(nil, @"Not a valid SDALDimension.");
            break;
    }
    return attribute;
}

/**
 Returns the corresponding NSLayoutAttribute for the given SDALAttribute.
 
 @return The layout attribute for the given SDALAttribute.
 */
+ (NSLayoutAttribute)al_attributeForSDALAttribute:(NSInteger)SDALAttribute
{
    NSLayoutAttribute attribute = NSLayoutAttributeNotAnAttribute;
    switch (SDALAttribute) {
        case SDALEdgeLeft:
            attribute = NSLayoutAttributeLeft;
            break;
        case SDALEdgeRight:
            attribute = NSLayoutAttributeRight;
            break;
        case SDALEdgeTop:
            attribute = NSLayoutAttributeTop;
            break;
        case SDALEdgeBottom:
            attribute = NSLayoutAttributeBottom;
            break;
        case SDALEdgeLeading:
            attribute = NSLayoutAttributeLeading;
            break;
        case SDALEdgeTrailing:
            attribute = NSLayoutAttributeTrailing;
            break;
        case SDALDimensionWidth:
            attribute = NSLayoutAttributeWidth;
            break;
        case SDALDimensionHeight:
            attribute = NSLayoutAttributeHeight;
            break;
        case SDALAxisVertical:
            attribute = NSLayoutAttributeCenterX;
            break;
        case SDALAxisHorizontal:
            attribute = NSLayoutAttributeCenterY;
            break;
        case SDALAxisBaseline:
            attribute = NSLayoutAttributeBaseline;
            break;
        default:
            NSAssert(nil, @"Not a valid SDALAttribute.");
            break;
    }
    return attribute;
}

/**
 Returns the corresponding UILayoutConstraintAxis for the given SDALAxis.
 
 @return The constraint axis for the given axis.
 */
+ (UILayoutConstraintAxis)al_constraintAxisForAxis:(SDALAxis)axis
{
    UILayoutConstraintAxis constraintAxis;
    switch (axis) {
        case SDALAxisVertical:
            constraintAxis = UILayoutConstraintAxisVertical;
            break;
        case SDALAxisHorizontal:
        case SDALAxisBaseline:
            constraintAxis = UILayoutConstraintAxisHorizontal;
            break;
        default:
            NSAssert(nil, @"Not a valid SDALAxis.");
            break;
    }
    return constraintAxis;
}

/**
 Returns the common superview for this view and the given peer view.
 Raises an exception if this view and the peer view do not share a common superview.
 
 @return The common superview for the two views.
 */
- (UIView *)al_commonSuperviewWithView:(UIView *)peerView
{
    UIView *commonSuperview = nil;
    UIView *startView = self;
    do {
        if ([peerView isDescendantOfView:startView]) {
            commonSuperview = startView;
        }
        startView = startView.superview;
    } while (startView && !commonSuperview);
    NSAssert(commonSuperview, @"Can't constrain two views that do not share a common superview. Make sure that both views have been added into the same view hierarchy.");
    return commonSuperview;
}

/**
 Aligns this view to a peer view with an alignment option.
 
 @param peerView The peer view to align to.
 @param alignment The alignment option to apply to the two views.
 @param axis The axis along which the views are distributed, used to validate the alignment option.
 @return The constraint added.
 */
- (NSLayoutConstraint *)al_alignToView:(UIView *)peerView withOption:(NSLayoutFormatOptions)alignment forAxis:(SDALAxis)axis
{
    NSLayoutConstraint *constraint = nil;
    switch (alignment) {
        case NSLayoutFormatAlignAllCenterX:
            NSAssert(axis == SDALAxisVertical, @"Cannot align views that are distributed horizontally with NSLayoutFormatAlignAllCenterX.");
            constraint = [self sdal_alignAxis:SDALAxisVertical toSameAxisOfView:peerView];
            break;
        case NSLayoutFormatAlignAllCenterY:
            NSAssert(axis != SDALAxisVertical, @"Cannot align views that are distributed vertically with NSLayoutFormatAlignAllCenterY.");
            constraint = [self sdal_alignAxis:SDALAxisHorizontal toSameAxisOfView:peerView];
            break;
        case NSLayoutFormatAlignAllBaseline:
            NSAssert(axis != SDALAxisVertical, @"Cannot align views that are distributed vertically with NSLayoutFormatAlignAllBaseline.");
            constraint = [self sdal_alignAxis:SDALAxisBaseline toSameAxisOfView:peerView];
            break;
        case NSLayoutFormatAlignAllTop:
            NSAssert(axis != SDALAxisVertical, @"Cannot align views that are distributed vertically with NSLayoutFormatAlignAllTop.");
            constraint = [self sdal_pinEdge:SDALEdgeTop toEdge:SDALEdgeTop ofView:peerView];
            break;
        case NSLayoutFormatAlignAllLeft:
            NSAssert(axis == SDALAxisVertical, @"Cannot align views that are distributed horizontally with NSLayoutFormatAlignAllLeft.");
            constraint = [self sdal_pinEdge:SDALEdgeLeft toEdge:SDALEdgeLeft ofView:peerView];
            break;
        case NSLayoutFormatAlignAllBottom:
            NSAssert(axis != SDALAxisVertical, @"Cannot align views that are distributed vertically with NSLayoutFormatAlignAllBottom.");
            constraint = [self sdal_pinEdge:SDALEdgeBottom toEdge:SDALEdgeBottom ofView:peerView];
            break;
        case NSLayoutFormatAlignAllRight:
            NSAssert(axis == SDALAxisVertical, @"Cannot align views that are distributed horizontally with NSLayoutFormatAlignAllRight.");
            constraint = [self sdal_pinEdge:SDALEdgeRight toEdge:SDALEdgeRight ofView:peerView];
            break;
        case NSLayoutFormatAlignAllLeading:
            NSAssert(axis == SDALAxisVertical, @"Cannot align views that are distributed horizontally with NSLayoutFormatAlignAllLeading.");
            constraint = [self sdal_pinEdge:SDALEdgeLeading toEdge:SDALEdgeLeading ofView:peerView];
            break;
        case NSLayoutFormatAlignAllTrailing:
            NSAssert(axis == SDALAxisVertical, @"Cannot align views that are distributed horizontally with NSLayoutFormatAlignAllTrailing.");
            constraint = [self sdal_pinEdge:SDALEdgeTrailing toEdge:SDALEdgeTrailing ofView:peerView];
            break;
        default:
            NSAssert(nil, @"Unsupported alignment option.");
            break;
    }
    return constraint;
}

@end
