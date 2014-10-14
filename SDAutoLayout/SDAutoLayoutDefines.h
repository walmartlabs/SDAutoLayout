//  SDAutoLayoutDefines.h
//
//  Created by Sam Grover on 10/01/2014.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//
//  Based on:
//
//  PureLayoutDefines.h
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

#ifndef SDAutoLayoutDefines_h
#define SDAutoLayoutDefines_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark SDALAttributes

/** Constants that represent edges of a view. */
typedef NS_ENUM(NSInteger, SDALEdge) {
    /** The left edge of the view. */
    SDALEdgeLeft = NSLayoutAttributeLeft,
    /** The right edge of the view. */
    SDALEdgeRight = NSLayoutAttributeRight,
    /** The top edge of the view. */
    SDALEdgeTop = NSLayoutAttributeTop,
    /** The bottom edge of the view. */
    SDALEdgeBottom = NSLayoutAttributeBottom,
    /** The leading edge of the view (left edge for left-to-right languages like English, right edge for right-to-left languages like Arabic). */
    SDALEdgeLeading = NSLayoutAttributeLeading,
    /** The trailing edge of the view (right edge for left-to-right languages like English, left edge for right-to-left languages like Arabic). */
    SDALEdgeTrailing = NSLayoutAttributeTrailing
};

/** Constants that represent dimensions of a view. */
typedef NS_ENUM(NSInteger, SDALDimension) {
    /** The width of the view. */
    SDALDimensionWidth = NSLayoutAttributeWidth,
    /** The height of the view. */
    SDALDimensionHeight = NSLayoutAttributeHeight
};

/** Constants that represent axes of a view. */
typedef NS_ENUM(NSInteger, SDALAxis) {
    /** A vertical line through the center of the view. */
    SDALAxisVertical = NSLayoutAttributeCenterX,
    /** A horizontal line through the center of the view. */
    SDALAxisHorizontal = NSLayoutAttributeCenterY,
    /** A horizontal line at the text baseline (not applicable to all views). */
    SDALAxisBaseline = NSLayoutAttributeBaseline
};

/** A block containing method calls to the SDAutoLayout API. Takes no arguments and has no return value. */
typedef void(^SDALConstraintsBlock)(void);

#endif /* SDAutoLayoutDefines_h */
