//
//  IFToolbarManager.h
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
#import "IFToolbarManagerDelegate.h"
#import "IFToolbarPane.h"
#import "NSWindow+Resizing.h"
#import "MAZeroingWeakRef.h"

/*
 The IF_ERROR_REPORTING_LEVEL macro allows you to set the level at which IFToolbarManager reports the errors from which it recovers. Setting
 IF_ERROR_REPORTING_LEVEL to 0 will allow IFToolbarManager to recover from errors silently (this is recommended for use in production
 applications to avoid logging). Setting it to 1 will alert you when IFToolbarManager encounters an error (this is highly  recommended for
 debugging issues which are difficult to test in GUI applications.
 */
#ifdef IF_ERROR_REPORTING_LEVEL
#undef IF_ERROR_REPORTING_LEVEL
#endif

#define IF_ERROR_REPORTING_LEVEL 1

/*!
 @class IFToolbarManager
 @abstract The main manager for a selectable toolbar.
 @discussion The IFToolbarManager class manages a selectable toolbar, populating it with toolbar items and managing the views its window
 will cycle through. The manager has a 1:1 relationship with toolbars (1 toolbar per manager, and vice versa), but can have a many:1
 relationship with a delegate (several toolbar managers per delegate object, usually a larger UI controller class). The toolbar passed to
 IFToolbarManager can be created either programmatically or through Interface Builder, and if there are any items on the toolbar, they will
 be kept and added to through the pane loading system. Although the manager makes no changes to the toolbar, it is highly recommended that
 the toolbar has customization turned off, not for reasons of compatibility, but because use of selectable toolbars usually exists in
 situations where allowing users to edit the toolbar is inappropriate.
 
 IFToolbarManager tries, when possible, to automate tasks to make use as easy as possible, but offers delegate methods to enhance
 customization. IFToolbarManager rests heavily on its identifier, reusing it whenever possible. If no identifier is passed to the manager,
 it will reuse its toolbar's identifier. IFToolbarManager uses this identifier to find the .xib file containing the panes used to populate
 its toolbar. If the identifier for the toolbar is @"MainToolbar", it will search for a MainToolbar.xib file to load its panes from, unless
 the delegate offers a different one.
 
 For its delegate, IFToolbarManager employs Michael Ash's MAZeroingWeakRef to avoid messaging a dangling pointer. The license for
 MAZeroingWeakRef is included below:
 */

/*! Copyright (c) 2010, Michael Ash
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 
 Neither the name of Michael Ash nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
@interface IFToolbarManager : NSObject <NSToolbarDelegate> {
	NSString *_identifier;
	NSToolbar *_toolbar;
	NSUInteger _selectedTag;
	
	NSMutableArray *_itemIdentifiers;
	NSMutableArray *_toolbarPanes;
	MAZeroingWeakRef *_delegateReference;
	MAZeroingWeakRef *_encapsulatedObjectReference;
}

@property (readonly) NSString *identifier;
@property (readonly) NSToolbar *toolbar;
@property (readonly) NSWindow *window;
@property (readonly) NSUInteger selectedTag;
@property (assign) id <IFToolbarManagerDelegate> delegate;
@property (assign) id encapsulatedObject;

/*!
 Creates a new toolbar manager with the given toolbar. Returns nil if the given toolbar is nil.
 @param theToolbar the toolbar to manage (precondition: theToolbar != nil)
 @return a new toolbar manager
 */
- (id)initWithToolbar:(NSToolbar *)theToolbar;

/*!
 Creates a new toolbar manager with the given toolbar. Returns nil if the given toolbar is nil. If the given identifier is nil, the manager
 will use the toolbar's identifier as its own.
 @param theToolbar the toolbar to manage (precondition: theToolbar != nil)
 @param theIdentifier the identifier to use
 @return a new toolbar manager with the given identifier
 */
- (id)initWithToolbar:(NSToolbar *)theToolbar identifier:(NSString *)theIdentifier;

/*!
 Creates a new toolbar manager with the given toolbar. Returns nil if the given toolbar is nil. If the given identifier is nil, the manager
 will use the toolbar's identifier as its own. The manager will employ the delegate to provide any customization options.
 @param theToolbar the toolbar to manage (precondition: theToolbar != nil)
 @param theIdentifier the identifier to use
 @param theDelegate the delegate to message
 @return a new toolbar manager with the given identifier and delegate
 */
- (id)initWithToolbar:(NSToolbar *)theToolbar identifier:(NSString *)theIdentifier delegate:(id <IFToolbarManagerDelegate>)theDelegate;

/*!
 Selects the pane of the next item on the toolbar. Does nothing if the last item is currently selected. Exposed to be used in Interface
 Builder to allow wizard-type applications to be created.
 @param sender the sender of the message
 */
- (IBAction)selectNextPane:(id)sender;

/*!
 Selects the pane of the previous item on the toolbar. Does nothing fi the first item is currently selected. Exposed to be used in Interface
 Builder to allow wizard-type applications to be created.
 @param sender the sender of the message
 */
- (IBAction)selectPreviousPane:(id)sender;

/*!
 If a toolbar item with the given identifier exists in the managed toolbar, it will be selected. Logs a message if such an item doesn't
 exist, and IF_ERROR_REPORTING_LEVEL is set to 1
 @param theIdentifier the identifier to select (precondition: theIdentifier != nil)
 */
- (void)selectToolbarItemWithIdentifier:(NSString *)theIdentifier;

@end