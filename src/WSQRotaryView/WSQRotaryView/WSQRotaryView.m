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
#import "WSQRotaryView.h"
#import "WSQRotarySegment.h"

#import <QuartzCore/QuartzCore.h>

#import "WSQRotaryViewDelegate.h"

@interface WSQRotaryView()

// private rotation property, we probably don't want this being poked at behind our back
@property (nonatomic, assign) float rotation;

@end

@implementation WSQRotaryView {
    double radius;
    double centerRadius;
    
    CGPoint middle;
    
    UIBezierPath *outerPath;
    UIBezierPath *centerPath;
    
    BOOL centerSelected;

    float rot;
    dispatch_source_t rotationAnimation;
    BOOL isAnimationRunning;
    
    // this contains all the info about the user's fingers
    struct {
        // __unsafe_unretained UITouch *trackingTouch;
        CGPoint previousLocation;
        CGPoint totalDelta;
        
        float startingRotation;
        
        BOOL isTrackingTouch;
        BOOL isTrackingCenterTouch;
    } touchInfo;
}

// Layout the subviews.
-(void) layoutSubviews
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    // make our radius either 45% of the width, or 50% of the height 
    radius = fmin(self.bounds.size.width * 0.9, self.bounds.size.height) * 0.5;
    middle = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
    // the center radius is 45% of the outer radius
    centerRadius = radius * 0.45;
    
    // create a couple of bezier paths for drawing & touch events
    outerPath = [UIBezierPath bezierPathWithArcCenter:middle radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    centerPath = [UIBezierPath bezierPathWithArcCenter:middle radius:centerRadius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
}

-(NSUInteger) segmentIndexForRotation:(float) rotation
{
    // calculate the increment between segments
    float incr = (M_PI * 2) / _segments.count;
    int selectedIndex = ((int) round(rotation / incr));
    
    // we need to flip the segment index around, because of the negative rotations used elsewhere
    selectedIndex = (_segments.count - selectedIndex) % _segments.count;
    
    return selectedIndex;
}

-(void) setSegments:(NSArray *)segments
{
    _segments = segments;

    // make sure we re-draw after the segments are set
    [self setNeedsDisplay];
    
    // and rotate ourselves to 0, then set the selected segment to the first item in the list
    [self setRotation:0];
    [self setSelectedSegment:_segments[0]];
}

-(void) setSelectedSegment:(WSQRotarySegment *)selectedSegment
{
    // animate the segment selection
    [self setSelectedSegment:selectedSegment animated:YES];
}

-(void) setSelectedSegment:(WSQRotarySegment *)selectedSegment animated:(BOOL) animated
{
    // animate the transition
    if (animated)
    {
        // we don't manually set the segment here - that's handled by the rotation process.
        int newIndex = [_segments indexOfObject:selectedSegment];
        
        // if we're trying to animate, but we don't know where to animate from, there's nothing to do
        if (newIndex == NSNotFound)
        {
            // just tell it to set without animation this time.
            [self setSelectedSegment:selectedSegment animated:NO];
            return;
        }
        
        // calculate the segment increment
        float angle = (M_PI * 2) / _segments.count;
        
        // start the animation from the current rotation, and take it to the inverse angle
        float oldRotation = rot;
        float newRotation = angle * ((_segments.count - newIndex) % _segments.count);
        
        // modulo the rotation by 2PI, to make sure we aren't over turning more than once
        newRotation = fmodf(newRotation, M_PI * 2);
        
        // these two blocks check for scenarios where we may not be taking the shortest rotation path
        if (oldRotation - newRotation > M_PI)
        {
            newRotation += M_PI * 2;
        }
        else if (newRotation - oldRotation > M_PI)
        {
            oldRotation += M_PI * 2;
        }
        
        // if the rotations are equivalent, then we have nothing to do!
        if (oldRotation == newRotation)
        {
            [self setSelectedSegment:selectedSegment animated:NO];
            return;
        }
        
        uint64_t interval = (NSEC_PER_SEC / 30.0); // shoot for 30 FPS
        
        // tracks the animation progress
        __block float progress = 0;
        
        if (rotationAnimation == nil) {
            // setup our timer for the first time
            rotationAnimation = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
            dispatch_source_set_timer(rotationAnimation, DISPATCH_TIME_NOW, interval, interval);
        }
        
        float difference = newRotation - oldRotation;
        dispatch_source_set_event_handler(rotationAnimation, ^{
            isAnimationRunning = YES;
            progress += (1.0 / 15.0);
            
            if (progress < 0)
                progress = 0;
            if (progress > 1)
                progress = 1;
            
            // basic linear interpolation
            float newAngle = (difference * progress) + oldRotation;
            [self setRotation:newAngle];
            
            if (progress >= 1) {
                dispatch_suspend(rotationAnimation);
                isAnimationRunning = NO;
            }
        });
        
        // if we already have an animation going, we must stop it
        if (isAnimationRunning)
            dispatch_suspend(rotationAnimation);
        
        // kick off the timer!
        dispatch_resume(rotationAnimation);
    }
    else
    {
        // give our delegate time to respond to the changes
        if ([self.delegate respondsToSelector:@selector(rotaryView:willSelectSegment:)])
        {
            [self.delegate rotaryView:self willSelectSegment:selectedSegment];
        }
        
        _selectedSegment = selectedSegment;
        
        // tell the delegate we did make changes
        if ([self.delegate respondsToSelector:@selector(rotaryView:didSelectSegment:)])
        {
            [self.delegate rotaryView:self didSelectSegment:selectedSegment];
        }
        
        // and, of course, re-draw.
        [self setNeedsDisplay];
    }
}

-(void) setRotation:(float)rotation
{
    // modulo the rotation by 2PI (so that we can tell if rotations are equivalent, and prevents multiple turns during animation)
    rotation = fmodf(rotation, M_PI * 2);
    
    if (rot != rotation) {
        rot = rotation;
        
        // update the selected segment, in case that changed
        [self setSelectedSegment:_segments[[self segmentIndexForRotation:rotation]] animated:NO];
        
        // then re-draw
        [self setNeedsDisplay];
    }
}

-(void) normalizeRotation
{
    // basically, all this method does is make our control 'snap' to the nearest segment.
    // that segment should always be the selected one, making this method very simple.
    [self setSelectedSegment:_selectedSegment animated:YES];
}

-(void) drawRect:(CGRect)rect
{
    // if we don't have any segments to draw, let's just not draw anything.
    if (!_segments.count)
        return;
    
    // 'angle' is the increment between segments
    float angle = (M_PI * 2) / _segments.count;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // save the graphics state, for when we draw the center
    CGContextSaveGState(context);
    
    // rotate the context around the middle by the current rotation (rot).
    CGContextTranslateCTM(context, middle.x, middle.y);
    CGContextRotateCTM(context, rot);
    CGContextTranslateCTM(context, -middle.x, -middle.y);
    
    // this tracks the incremental rotation between segments
    float rotation = 0;
    
    for (WSQRotarySegment *segment in _segments)
    {
        // set the radius, angle, and selected properties of the segment here.
        // while this may be called every time we draw, it's the best way to
        // ensure that their state remains in-synch
        segment.radius = radius;
        segment.angle = angle;
        segment.isSelected = segment == self.selectedSegment;
        
        // save our graphics state again, so we can undo the rotate
        CGContextSaveGState(context);
        
        // first, we translate to put the middle of the circle at 0, 0
        CGContextTranslateCTM(context, middle.x, middle.y);
        
        // then we rotate on top of that, so that when they draw an arc from 90 degrees to 90 degrees + angle,
        // it draws where it's supposed to be
        CGContextRotateCTM(context, rotation);
        
        // have the segment draw itself
        [segment drawInContext:context];
        
        // restore our graphics state once, undoing the rotation
        CGContextRestoreGState(context);
        
        // and finally, increment our angle
        rotation += angle;
    }
    
    // undo the initial rotation of the context
    CGContextRestoreGState(context);
    
    // and draw our center.
    [self drawCenter:context];
}

-(void) drawCenter:(CGContextRef) context
{
    // draw our center gradient, by initializing our colors array.
    NSArray *colors =
    @[
        (__bridge id) [self.innerGradientNormalColor CGColor],
        (__bridge id) [self.outerGradientNormalColor CGColor],
    ];
    
    // make sure we have the right colors in case of the center being selected
    if (centerSelected) {
        colors = @[
            (__bridge id) [self.innerGradientSelectedColor CGColor],
            (__bridge id) [self.outerGradientSelectedColor CGColor],
        ];
    }
    
    // create the gradient
    CGGradientRef gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), (__bridge CFArrayRef) colors, NULL);

    // add the middle circle
    CGContextAddPath(context, [centerPath CGPath]);
    
    // save the graphics state, because of the clip we are doing below
    CGContextSaveGState(context);
    
    // clip the context to the center circle so that the cicle doesn't go farther than our radius
    CGContextClip(context);
    
    // then we get to finally draw the gradient
    CGContextDrawRadialGradient(context, gradient, middle, 0, middle, centerRadius, kCGGradientDrawsAfterEndLocation);
    
    // restore our graphics state, removing the clip
    CGContextRestoreGState(context);
    
    // re-add our path, as it was removed when we draw
    CGContextAddPath(context, [centerPath CGPath]);
    
    // finally, we stroke the outside of it, with a 2px black border
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetLineWidth(context, 2);
    
    CGContextStrokePath(context);
    
    // draw our center string
    CGSize contactSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(centerRadius * 1.75, centerRadius * 1.75) lineBreakMode:NSLineBreakByWordWrapping];
    
    // we aren't using the CGContext methods here, as they are much more involved than NSString methods.
    // If you do need to draw this to another context (other than the UIGraphicsCurrentContext()), use the UIGraphicsPushContext method.
    [self.textColor setFill];
    [self.text
     drawInRect:
     CGRectMake(
                middle.x - (contactSize.width / 2),
                middle.y - (contactSize.height / 2),
                contactSize.width,
                contactSize.height
                )
     withFont:self.font
     lineBreakMode:NSLineBreakByWordWrapping
     alignment:NSTextAlignmentCenter];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // if we're already tracking touches, leave these ones alone. It will only lead to confusion down the road.
    if (touchInfo.isTrackingTouch || touchInfo.isTrackingCenterTouch)
        return;
    
    CGPoint location = [[touches anyObject] locationInView:self];
    
    // if it's in the center, then we need to change our center gradients
    if ([centerPath containsPoint:location])
    {
        // we're tracking a center touch
        touchInfo.isTrackingCenterTouch = YES;
        centerSelected = YES;
        
        [self setNeedsDisplay];
    }
    else if ([outerPath containsPoint:location])
    {
        // here we begin tracking for the drag & tap actions
        touchInfo.isTrackingTouch = YES;
        
        // the starting rotation is the current rotation, plus the angle of the touch, modulo'd by 2PI
        touchInfo.startingRotation = fmodf(rot + atan2f(middle.x - location.x, middle.y - location.y), M_PI * 2);
    }
    
    touchInfo.previousLocation = location;
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // if we're not currently tracking a touch, then we probably shouldn't be knowing when it's moving
    if (touchInfo.isTrackingTouch == NO && touchInfo.isTrackingCenterTouch == NO)
        return;
    
    CGPoint location = [[touches anyObject] locationInView:self];
    
    if (touchInfo.isTrackingCenterTouch)
    {
        // if we're tracking the center touch, and the center no longer contains the touch,
        // then obviously the center is no longer selected.
        if (![centerPath containsPoint:location])
        {
            // reset our touch info, and re-draw.
            touchInfo = (typeof(touchInfo)) { 0 };
            centerSelected = NO;
            
            [self setNeedsDisplay];
            return;
        }
    }
    if (touchInfo.isTrackingTouch)
    {
        // if the touch goes outside of the outer circle, then we should stop tracking it.
        if (![outerPath containsPoint:location])
        {
            // reset the touch info, 
            touchInfo = (typeof(touchInfo)) { 0 };
            
            // and jump to the closest item, and call it good
            [self normalizeRotation];
            
            
            return;
        }
        
        // otherwise, add the movement of this touch to the delta we have stored
        // (if the touch moves any more than 3px total, then it's a drag, not a tap)
        touchInfo.totalDelta.x += abs(touchInfo.previousLocation.x - location.x);
        touchInfo.totalDelta.y += abs(touchInfo.previousLocation.y - location.y);
        
        if ((touchInfo.totalDelta.x + touchInfo.totalDelta.y) > 3)
        {
            // otherwise, let's update our rotation with our delta
            // first, we need to get the angle where the finger is currently tracking
            float angle = atan2f(middle.x - location.x, middle.y - location.y);

            // then update our rotation accordingly
            [self setRotation:touchInfo.startingRotation - angle];
        }
    }
    
    touchInfo.previousLocation = location;
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // if we're not currently tracking a touch, then we probably shouldn't be knowing when it's moving
    if (touchInfo.isTrackingTouch == NO && touchInfo.isTrackingCenterTouch == NO)
        return;
    
    CGPoint location = [[touches anyObject] locationInView:self];
    
    if (touchInfo.isTrackingCenterTouch)
    {
        // if we're still in the center, then let our delegate know that the middle was tapped.
        if ([centerPath containsPoint:location])
        {
            if ([self.delegate respondsToSelector:@selector(rotaryViewDidTapCenterButton:)])
            {
                [self.delegate rotaryViewDidTapCenterButton:self];
            }
        }
        
        // reset our touch info
        touchInfo = (typeof(touchInfo)) { 0 };
        centerSelected = NO;
        
        [self setNeedsDisplay];
    }
    if (touchInfo.isTrackingTouch)
    {
        if (![outerPath containsPoint:location])
        {
            // the user dragged outside of our outer circle. 
            // reset our touch info, then normalize our rotation.
            touchInfo = (typeof(touchInfo)) { 0 };
            [self normalizeRotation];
        }
        
        // the user has dragged the wheel if the total delta is more than 3.
        if ((touchInfo.totalDelta.x + touchInfo.totalDelta.y) > 3)
        {
            // make sure we snap to the nearest segment.
            [self normalizeRotation];
        }
        
        // in this case, the segment was tapped, not  dragged.
        else
        {
            // select the segment that is being tapped.
            // this is calculated by the current rotation,
            // and the arctan of the final touch location, modulo'd by 2PI
            float angle = fmodf(rot + atan2f(middle.x - location.x, middle.y - location.y), M_PI * 2);
            
            // get the segment index, and animate to it.
            int selectedIndex = [self segmentIndexForRotation:angle];
            [self setSelectedSegment:_segments[selectedIndex] animated:YES];
        }
        
        // reset our touch info
        touchInfo = (typeof(touchInfo)) { 0 };
    }
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // nothing special when the touches cancel, just go to the touches ended
    [self touchesEnded:touches withEvent:event];
}

@end
