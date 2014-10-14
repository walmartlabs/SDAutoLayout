//  SDAutoLayout+Internal.h
//
//  Created by Sam Grover on 10/01/2014.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//
//  Based on:
//
//  PureLayout+Internal.h
//  v1.1.0
//  https://github.com/smileyborg/PureLayout
//
//  Copyright (c) 2014 Tyler Fox
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


/**
 A category that exposes the internal (private) helper methods of the UIView+SDAutoLayout category.
 */
@interface UIView (SDAutoLayoutInternal)

+ (NSLayoutAttribute)al_attributeForEdge:(SDALEdge)edge;
+ (NSLayoutAttribute)al_attributeForAxis:(SDALAxis)axis;
+ (NSLayoutAttribute)al_attributeForDimension:(SDALDimension)dimension;
+ (NSLayoutAttribute)al_attributeForSDALAttribute:(NSInteger)SDALAttribute;
+ (UILayoutConstraintAxis)al_constraintAxisForAxis:(SDALAxis)axis;

- (void)al_addConstraintUsingGlobalPriority:(NSLayoutConstraint *)constraint;
- (UIView *)al_commonSuperviewWithView:(UIView *)peerView;
- (NSLayoutConstraint *)al_alignToView:(UIView *)peerView withOption:(NSLayoutFormatOptions)alignment forAxis:(SDALAxis)axis;

@end


/**
 A category that exposes the internal (private) helper methods of the NSArray+SDAutoLayout category.
 */
@interface NSArray (SDAutoLayoutInternal)

- (UIView *)al_commonSuperviewOfViews;
- (BOOL)al_containsMinimumNumberOfViews:(NSUInteger)minimumNumberOfViews;
- (NSArray *)al_copyViewsOnly;

@end
