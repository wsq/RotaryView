#WSQRotaryView

WSQRotaryView is an [open-source][LICENSE] rotating radial menu implementation, created by [Why Status Quo, Inc][wsq-link]. It supports custom colors, fonts, icons and sizes.

Design Goals:
    
  - Easy to set-up  
    - The latest build of the libary is packaged as a .framework folder in the root of the repository
    - Drag and drop the framework into your Xcode project
    - Add the `objc` and `all_load` in the 'Other Linker Flags' section of Xcode's build settings.  
  <br>
  - Simple to use
    - Drag the wheel to your selected segment, release, and tap the middle button, or
    - Tap the segment you want, then tap the middle button to activate.

Limitations:

  - Can only support ~6 items in the wheel at a time, as you will run out of space
  - Uses CoreGraphics for drawing, which may lead to sub-optimal rendering on older devices
  - Inertia is not currently supported, the wheel simply  'snaps' to the nearest segment when the touch is released
  - Requires iOS 5.0 & later (for ARC, the new objective-c literals syntax, and weak references)

Video Demo:

[![Video Screenshot][video-screenshot]][video-demo]

Legal Stuff:

> <sub>The contents of this file are subject to the Common Public Attribution License Version 1.0 (the “License”);  you may not use this file except in compliance with the License. You may obtain a copy of the License at http://opensource.org/licenses/CPAL-1.0  
> The License is based on the Mozilla Public License Version 1.1 but Sections 14 and 15 have been added to cover use of software over a computer network and provide for limited attribution for the Original Developer. In addition, Exhibit A has been modified to be consistent with Exhibit B.
> Software distributed under the License is distributed on an “AS IS” basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the specific language governing rights and limitations under the License.  
> The Original Code is http://github.com/wsq/RotaryView
> The Initial Developer of the Original Code is Why Status Quo? Inc. All portions of the code written by Why Status Quo? Inc. are Copyright (c) 2013 Why Status Quo? Inc. All Rights Reserved. </sub>  

 [LICENSE]: http://opensource.org/licenses/CPAL-1.0
 [wsq-link]: http://whystatusquo.com
 [video-demo]: http://www.youtube.com/watch?v=F3Gy7q64B-E
 [video-screenshot]: http://i.imgur.com/C3ryQuom.png
