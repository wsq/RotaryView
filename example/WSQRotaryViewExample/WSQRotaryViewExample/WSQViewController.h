//
//  WSQViewController.h
//  WSQRotaryViewExample
//
//  Created by Richard Ross on 3/17/13.
//  Copyright (c) 2013 Why Status Quo? Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WSQRotaryView/WSQRotaryView.h>

@interface WSQViewController : UIViewController<WSQRotaryViewDelegate>

@property IBOutlet WSQRotaryView *rotaryView;

@end
