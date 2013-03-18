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

#import <Foundation/Foundation.h>

@class WSQRotaryView;
@class WSQRotarySegment;

@protocol WSQRotaryViewDelegate <NSObject>

@optional
-(void) rotaryView:(WSQRotaryView *) rotaryView willSelectSegment:(WSQRotarySegment *) segment;
-(void) rotaryView:(WSQRotaryView *) rotaryView didSelectSegment:(WSQRotarySegment *) segment;
-(void) rotaryViewDidTapCenterButton:(WSQRotaryView *) rotaryView;

@end