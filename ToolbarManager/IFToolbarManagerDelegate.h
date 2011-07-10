//
//  IFToolbarManagerDelegate.h
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
 @protocol IFToolbarManagerDelegate
 @abstract Defines optional methods used by the delegate of an IFToolbarManager to offer customizations.
 @discussion The IFToolbarManagerDelegate protocol defines methods that a delegate can use to offer customizations for a given toolbar. All
 methods are optional; if a delegate does not respond to a method, a default value will be used. If the delegate responds to a method with
 an invalid response (returns nil, or an invalid value), the toolbar manager will log the incident, and use a default value instead. In
 these methods, the passed toolbar will never be nil.
 */
@protocol IFToolbarManagerDelegate <NSObject>
@optional
/*!
 Returns the name of a xib file to use for a given toolbar (and manager), instead of the default identifier of the manager (e.g. a manager
 can have an identifier of @"IFMainToolbarManager" but search for an xib file called @"ToolbarPanes").
 @param theToolbar the toolbar for which to return an associate xib name
 @return the name of the xib file to search for and attempt to load
 */
- (NSString *)toolbarAssociatedXibName:(NSToolbar *)theToolbar;

/*!
 Returns the default item identifier to select, if not the first toolbar item. If the delegate returns an identifier not found in the given
 toolbar, the manager will log the incident and use a default value instead.
 @param theToolbar the toolbar for which to return a default item identifier
 @return the default item identifier to select
 */
- (NSString *)toolbarDefaultSelectedItemIdentifier:(NSToolbar *)theToolbar;

/*!
 Returns whether the manager should attempt to pad the toolbar items so that they are in the center of the toolbar (by inserting 
 NSToolbarFlexibleSpaceItems on either side of the regular items). If the delegate does not respond to this method, by default items are not
 centered.
 @param theToolbar the toolbar for which to return whether items should be centered
 @return whether toolbar items should be centered
 */
- (BOOL)toolbarShouldCenterToolbarItems:(NSToolbar *)theToolbar;

/*!
 Returns the label to use for a toolbar item with the given identifier, instead of using the identifier itself. The returned value will be
 used as both the label and the palette label (which are, in the majority of cases, the same anyway). If nil is returned, the manager will
 log the incident, and will use the identifier instead.
 @param theToolbar the toolbar for which to return the label
 @param theIdentifier the identifier to create a label for
 @return the label to use for a toolbar item
 */
- (NSString *)toolbar:(NSToolbar *)theToolbar labelForItemWithIdentifier:(NSString *)theIdentifier;

/*!
 Returns the image for a toolbar item with the given identifier, instead of using [NSImage imageNamed:theIdentifier]. If the delegate
 returns nil, a default image will be loaded with `imageNamed:`.
 @param theToolbar the toolbar for which to return an image
 @param theIdentifier the identifier for the item for which to give the image
 @return the image to use for a toolbar item
 */
- (NSImage *)toolbar:(NSToolbar *)theToolbar imageForItemWithIdentifier:(NSString *)theIdentifier;
@end