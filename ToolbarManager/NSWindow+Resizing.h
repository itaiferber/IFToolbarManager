//
//  NSWindow+Resizing.h
//  ToolbarManager
//
//  Created by Itai Ferber on 7/8/11.
//  Copyright 2011 Itai Ferber. All rights reserved.
//

#import <AppKit/AppKit.h>

/*!
 @category NSWindow (Resizing)
 @abstract Resizing category used to switch content views.
 @discussion This category is used by IFToolbarManager to replace its toolbar's window's content view with different panes, using an 
 animation.
 */
@interface NSWindow (Resizing)
/*!
 Resizes the window to accept the given view as its content view with an animation, and replaces the content view.
 @param theView the new content view to set (precondition: theView != nil)
 */
- (void)setContentViewWithResize:(NSView *)theView;
@end