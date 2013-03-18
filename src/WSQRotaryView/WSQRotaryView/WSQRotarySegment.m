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

#import "WSQRotarySegment.h"

#define NINETY_DEGREES (M_PI / 2)

@implementation WSQRotarySegment

-(id) initWithTitle:(NSString *)title icon:(UIImage *)icon font:(UIFont *)font background:(UIColor *)background selected:(UIColor *)selected textColor:(UIColor *)text borderColor:(UIColor *)border borderWidth:(double)width
{
    // make sure we call the right method for subclassing, so that default values can be initialzed
    if ((self = [WSQRotarySegment instanceMethodForSelector:@selector(init)](self, _cmd)))
    {
        self.title = title;
        self.icon = icon;
        self.textFont = font;
        self.backgroundColor =background;
        self.selectedTintColor = selected;
        self.textColor = text;
        self.borderColor = border;
        self.borderWidth = width;
    }
    
    return self;
}

-(id) init
{
    if ((self = [super init]))
    {
        // here is where you would initialize default values for this rotary segment
    }
    
    return self;
}

-(void) drawInContext:(CGContextRef)context
{
    // here's where the segment is drawn. these angles are the boundaries of the
    // arc that is drawn on-screen, and where all content should be placed between.
    float startAngle = NINETY_DEGREES - _angle / 2;
    float endAngle = NINETY_DEGREES + _angle / 2;
    float midAngle = ((endAngle - startAngle) / 2) + startAngle;
    
    // draw the background
    if (_backgroundColor != nil) {
        // the background is fairly simple. we draw an arc, with a center of (0, 0),
        // with the angle measures and radius defined by the rotary view.
        CGContextMoveToPoint(context, 0, 0);
        
        // add the arc
        CGContextAddArc(context, 0, 0, -_radius, startAngle, endAngle, NO);
        
        // and close up the path
        CGContextClosePath(context);
        
        [_backgroundColor setFill];
        [_borderColor setStroke];
        
        // fill, and stroke the wedge
        CGContextSetLineWidth(context, _borderWidth);
        CGContextDrawPath(context, kCGPathFillStroke);
        
        if (_isSelected)
        {
            // draw our arc again, with a different color
            [_selectedTintColor setFill];
            
            CGContextMoveToPoint(context, 0, 0);
            
            CGContextAddArc(context, 0, 0, -_radius, startAngle, endAngle, NO);
            CGContextClosePath(context);
            
            CGContextDrawPath(context, kCGPathFillStroke);
        }
    }
    
    // draw the text
    if (_title != nil &&
        _textColor != nil &&
        _textFont != nil)
    {
        // first we need to measure the text so that we can center it inside our arc.
        CGSize textSize = [_title sizeWithFont:_textFont];
        
        CGContextSetTextDrawingMode(context, kCGTextFill);
        
        // because of how core graphics handles text drawing, we need to flip the text on the Y axis.
        CGContextSetTextMatrix(context, CGAffineTransformScale(CGAffineTransformIdentity, 1, -1));
        
        // use some basic trigonomotry to determine where the text should be drawn
        float textX = cosf(midAngle) * (_radius * 0.9);
        float textY = -sinf(midAngle) * (_radius * 0.9);
        
        // center horizontal
        textX -= textSize.width / 2;
        
        // move the text back to its intended position (because of the -1 scale operation).
        textY += textSize.height / 2;
    
        // set the text postion
        CGContextSetTextPosition(context, textX, textY);
        
        [_textColor setFill];
    
        // set the font
        CGContextSelectFont(context, [[_textFont fontName] UTF8String], [_textFont pointSize], kCGEncodingMacRoman);
        
        // and draw the text
        CGContextShowText(context, [[self title] UTF8String], [[self title] length]);
    }
    
    // draw the icon
    if (_icon != nil)
    {
        CGSize iconSize = [_icon size];
        
        // use some trigonometry to determine where to draw the icon
        float left = cosf(midAngle) * (_radius * 0.75);
        float top = sinf(midAngle) * (_radius * 0.75);
        
        // center horizontal
        left -= iconSize.width / 2;
        
        // save the graphics state, as we will be messing with the CTM to ensure that it's flipped correctly (due to our rotations done above)
        CGContextSaveGState(context);
        
        // move the icon downwards, then flip it horizontally, esentially making it move upwards a bit
        CGContextTranslateCTM(context, 0, iconSize.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        // draw the image
        CGContextDrawImage(context, CGRectMake(left, top, iconSize.width, iconSize.height), [_icon CGImage]);
        
        // then restore our graphics state.
        CGContextRestoreGState(context);
    }
}

@end
