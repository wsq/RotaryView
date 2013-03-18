//
//  WSQViewController.m
//  WSQRotaryViewExample
//
//  Created by Richard Ross on 3/17/13.
//  Copyright (c) 2013 Why Status Quo? Inc. All rights reserved.
//

#import "WSQViewController.h"

@interface WSQViewController ()

@end

@implementation WSQViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *backgroundColor = [UIColor colorWithHue:1.0 saturation:0.33 brightness:0.75 alpha:1];
    UIColor *selectedColor = [UIColor colorWithHue:0.66 saturation:0.33 brightness:0.75 alpha:1];
    
    UIColor *textColor = [UIColor blackColor];
    UIColor *bordercolor = [UIColor blackColor];
    UIFont *font = [UIFont systemFontOfSize:15];
    
    // set-up the rotary view's segments
    self.rotaryView.segments = @[
        [[WSQRotarySegment alloc]
            initWithTitle:@"Facebook"
                     icon:[UIImage imageNamed:@"segment_facebook"]
                     font:font
               background:backgroundColor
                 selected:selectedColor
                textColor:textColor
              borderColor:bordercolor
              borderWidth:2],
        
        [[WSQRotarySegment alloc]
            initWithTitle:@"Twitter"
                     icon:[UIImage imageNamed:@"segment_twitter"]
                     font:font
               background:backgroundColor
                 selected:selectedColor
                textColor:textColor
              borderColor:bordercolor
              borderWidth:2],
        
        [[WSQRotarySegment alloc]
            initWithTitle:@"Email"
                     icon:[UIImage imageNamed:@"segment_email"]
                     font:font
               background:backgroundColor
                 selected:selectedColor
                textColor:textColor
              borderColor:bordercolor
               borderWidth:2],
        
        
        [[WSQRotarySegment alloc]
            initWithTitle:@"Phone"
                     icon:[UIImage imageNamed:@"segment_phone"]
                     font:font
               background:backgroundColor
                 selected:selectedColor
                textColor:textColor
              borderColor:bordercolor
              borderWidth:2],
    ];
    
    self.rotaryView.textColor = textColor;
    self.rotaryView.font = font;
    
    self.rotaryView.innerGradientNormalColor = backgroundColor;
    self.rotaryView.outerGradientNormalColor = selectedColor;
    
    self.rotaryView.innerGradientSelectedColor = selectedColor;
    self.rotaryView.outerGradientSelectedColor = [UIColor colorWithHue:1.0 saturation:0.33 brightness:0.85 alpha:1];
}

#pragma mark - WSQRotaryViewDelegate

-(void) rotaryView:(WSQRotaryView *)rotaryView didSelectSegment:(WSQRotarySegment *)segment
{
    rotaryView.text = [NSString stringWithFormat:@"Tap to do something with %@", segment.title];
}

-(void) rotaryViewDidTapCenterButton:(WSQRotaryView *)rotaryView
{
    NSString *message = [NSString stringWithFormat:@"You selected the %@ button!", rotaryView.selectedSegment.title];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:rotaryView.selectedSegment.title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}

@end
