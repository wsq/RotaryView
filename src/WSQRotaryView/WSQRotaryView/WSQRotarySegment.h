/*
 The contents of this file are subject to the Common Public Attribution License Version 1.0 (the “License”);
 you may not use this file except in compliance with the License.
 
 You may obtain a copy of the License at http://opensource.org/licenses/CPAL-1.0
 
 The License is based on the Mozilla Public License Version 1.1 but Sections 14 and 15 have been added to cover use
 of software over a computer network and provide for limited attribution for the Original Developer. In addition,
 Exhibit A has been modified to be consistent with Exhibit B.
 
 Software distributed under the License is distributed on an “AS IS” basis, WITHOUT WARRANTY OF ANY KIND,
 either express or implied. See the License for the specific language governing rights and limitations under the License.
 
 The Original Code is http://github.com/wsq/RotaryView
 The Initial Developer of the Original Code is Why Status Quo? Inc. All portions of the code written by
 Why Status Quo? Inc. are Copyright (c) 2013 Why Status Quo? Inc. All Rights Reserved.
 */

#import <UIKit/UIKit.h>

@interface WSQRotarySegment : NSObject

// initializer, to help with the instantiation of items
-(id) initWithTitle:(NSString *) title icon:(UIImage *) icon font:(UIFont *) font background:(UIColor *) background selected:(UIColor *) selected textColor:(UIColor *) text borderColor:(UIColor *) border borderWidth:(double) width;

// the title to be displayed along with the icon
@property (nonatomic, copy) NSString *title;

// the icon to be displayed along with the title
@property (nonatomic, strong) UIImage *icon;

// the colors which can be customized for the segment
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *selectedTintColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *borderColor;

// the font to use for the text
@property (nonatomic, strong) UIFont *textFont;

// a user-info property that can be used to identify this segment from others
@property (nonatomic, assign) int identifier;
@property (nonatomic, assign) BOOL isSelected;

// the following two properties should not be touched by the caller.
// they are all set and constantly updated by the rotary view itself.

// the angle of this segment, in radians
@property (nonatomic, assign) double angle;

// the radius of this segment.
@property (nonatomic, assign) double radius;

// the width of the border that is drawn around the segment
@property (nonatomic, assign) double borderWidth;

// this context is pre-rotated for the segment
-(void) drawInContext:(CGContextRef) context;

@end
