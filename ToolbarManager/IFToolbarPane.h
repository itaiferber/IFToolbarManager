//
//  IFToolbarPane.h
//  ToolbarManager
//
//  Created by Itai Ferber on 7/8/11.
//  Copyright 2011 Itai Ferber. All rights reserved.
//

/*
 Copyright (C) 2011 by Itai Ferber
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import <Cocoa/Cocoa.h>

/*!
 @class IFToolbarPane
 @abstract A class used for bindings between an NSView created in Interface Builder and the IFToolbarManager.
 @discussion IFToolbarPanes are to be used in Interface Builder to represent panes to switch to in the toolbar's window. To properly create
 an IFToolbarPane, one must create a default NSObject in Interface Builder, and set its class to IFToolbarPane. Then, the pane must be bound
 to the view that it represents, and under the "User Defined Runtime Attributes" section of its identity inspector, one must register the
 identifier and tag keys.
 
 In order for a toolbar pane's view to resize correctly as the window's content view, the toolbar manager must set the pane's view's
 autoresizingmask to NSViewNotSizable. This saves you the hassle of doing it manually in Interface Builder.
 
 The toolbar pane's identifier is the same identifier used throughout IFToolbarManager to create a toolbar item. A pane with identifier
 @"Install" will create a toolbar item with identifier @"Install", which will by default have the label @"Install" and an icon called
 @"Install", unless the toolbar manager's delegate customizes some behaviour. Obviously, the identifier must be registered as an NSString,
 or, better yet, a localized string. If a toolbar pane is not registered with an identifier (i.e. if you forget to register a value), the
 manager will log the incident.
 
 The toolbar pane's tag serves the purpose of allowing the manager to order the toolbar items, once created. Tags must be unsigned integers
 (recommended starting point is 0), and the manager will attempt to order tags in least-to-greatest order. If you forget to register the 
 tag, the default value will become 0. Since tags are used for this ordering, two panes with the same tag will become "unordered", and it is
 undefined in which order they will appear (though still after ones items with lower tags, and before ones with higher ones).
 */
@class IFToolbarManager;
@interface IFToolbarPane : NSObject {
	__unsafe_unretained NSView *_view;
	__strong NSString *_identifier;
	__strong NSNumber *_tag;
}

@property (assign) IBOutlet NSView *view;
@property (readonly) NSString *identifier;
@property (readonly) NSNumber *tag;

@end