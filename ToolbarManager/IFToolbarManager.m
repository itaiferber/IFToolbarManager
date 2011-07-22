//
//  IFToolbarManager.m
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

#import "IFToolbarManager.h"

#if IF_ERROR_REPORTING_LEVEL == 1
#define IFLog(...) NSLog(__VA_ARGS__)
#else
#define IFLog(...)
#endif

@interface IFToolbarManager ()
- (IFToolbarPane *)toolbarPaneWithIdentifier:(NSString *)theIdentifier;
- (IFToolbarPane *)selectedPane;
- (void)selectToolbarItem:(NSToolbarItem *)theItem;
@end

@implementation IFToolbarManager

#pragma mark - Synthesis
@synthesize identifier = _identifier;
@synthesize toolbar = _toolbar;
@synthesize selectedTag = _selectedTag;

#pragma mark - Initialization
- (id)initWithToolbar:(NSToolbar *)theToolbar {
	if (!theToolbar) return nil;
	if ((self = [super init])) {
		_identifier = [[theToolbar identifier] copy];
#if __has_feature(objc_arc)
		_toolbar = theToolbar;
		_delegate = nil;
		_encapsulatedObject = nil;
#else
		_toolbar = [theToolbar retain];
		_delegateReference = nil;
		_encapsulatedObjectReference = nil;
#endif
		[_toolbar setDelegate:self];
		_selectedTag = 0;
		_itemIdentifiers = [[NSMutableArray alloc] init];
		_toolbarPanes = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (id)initWithToolbar:(NSToolbar *)theToolbar identifier:(NSString *)theIdentifier {
	if (!theToolbar) return nil;
	if ((self = [super init])) {
		_identifier = theIdentifier ? [theIdentifier copy] : [[theToolbar identifier] copy];
#if __has_feature(objc_arc)
		_toolbar = theToolbar;
		_delegate = nil;
		_encapsulatedObject = nil;
#else
		_toolbar = [theToolbar retain];
		_delegateReference = nil;
		_encapsulatedObjectReference = nil;
#endif
		[_toolbar setDelegate:self];
		_selectedTag = 0;
		_itemIdentifiers = [[NSMutableArray alloc] init];
		_toolbarPanes = [[NSMutableArray alloc] init];
	}
	
	return self;
}

#pragma mark - Deallocation
- (void)dealloc {
#if !__has_feature(objc_arc)
	[_identifier release];
	[_toolbar release];
	[_itemIdentifiers release];
	[_toolbarPanes release];
	[_delegateReference release];
#endif
	_identifier = nil;
	_toolbar = nil;
	_itemIdentifiers = nil;
	_toolbarPanes = nil;
#if __has_feature(objc_arc)
	_delegate = nil;
	_encapsulatedObject = nil;
#else
	_delegateReference = nil;
	_encapsulatedObjectReference = nil;
	[super dealloc];
#endif
}

#pragma mark - Customized Access
- (NSWindow *)window {
	return [_toolbar valueForKey:@"_window"];
}

- (void)setEncapsulatedObject:(id)theObject {
#if __has_feature(objc_arc)
	_encapsulatedObject = theObject;
#else
	[_encapsulatedObjectReference release];
	_encapsulatedObjectReference = [[MAZeroingWeakRef alloc] initWithTarget:theObject];
#endif
}

- (id)encapsulatedObject {
#if __has_feature(objc_arc)
	return _encapsulatedObject;
#else
	return [_encapsulatedObjectReference target];
#endif
}

#pragma mark - Loading
- (void)load {
#if __has_feature(objc_arc)
	id <IFToolbarManagerDelegate> delegate = _delegate;
#else
	id <IFToolbarManagerDelegate> delegate = [_delegateReference target];
#endif
	NSString *path = nil;
	if (delegate && [delegate respondsToSelector:@selector(toolbarAssociatedXibName:)]) {
		path = [delegate toolbarAssociatedXibName:_toolbar];
		if (![[NSBundle mainBundle] pathForResource:path ofType:@"nib"]) {
			IFLog(@"Delegate responded with an invalid value (%@) for `toolbarAssociatedXibName:`. Attempting default value (%@).", path, _identifier);
			path = nil;
		}
	}
	if (!path) path = _identifier;
	
	if (![[NSBundle mainBundle] pathForResource:path ofType:@"nib"]) {
		IFLog(@"Could not locate default %@.xib. Aborting.", path);
		return;
	}
	
	NSMutableArray *topLevelObjects = [NSMutableArray array];
	[[NSBundle mainBundle] loadNibFile:path externalNameTable:[NSDictionary dictionaryWithObjectsAndKeys:self, NSNibOwner, topLevelObjects, NSNibTopLevelObjects, nil] withZone:nil];
	NSArray *panes = [[topLevelObjects objectsAtIndexes:[topLevelObjects indexesOfObjectsPassingTest:^(id object, NSUInteger index, BOOL *stop) {
		return [object isKindOfClass:[IFToolbarPane class]];
	}]] sortedArrayUsingComparator:^(id firstObject, id secondObject) {
		NSUInteger firstTag = [((IFToolbarPane *)firstObject).tag unsignedIntegerValue], secondTag = [((IFToolbarPane *)secondObject).tag unsignedIntegerValue];
		return (NSComparisonResult)(firstTag < secondTag ? NSOrderedAscending : firstTag > secondTag ? NSOrderedDescending : NSOrderedSame);
	}];
	
	for (IFToolbarPane *pane in panes) {
		if (!pane.identifier) {
			IFLog(@"Encountered a pane without an identifier (identifier wasn't properly registered in Interface Builder). Ignoring.");
			continue;
		}
		
		if (!pane.tag) {
			IFLog(@"Encountered a pane without a tag (identifier: %@). Tag set by default to 0.", pane.identifier);
			[pane setValue:[NSNumber numberWithUnsignedInteger:0] forKeyPath:@"tag"];
		}
		
		[pane.view setAutoresizingMask:NSViewNotSizable];
		[_toolbarPanes addObject:pane];
		[_toolbarPanes sortUsingComparator:^(id firstObject, id secondObject) {
			return [((IFToolbarPane *)firstObject).tag compare:((IFToolbarPane *)secondObject).tag];
		}];
		
		__block NSUInteger insertIndex = [[_toolbar items] count];
		[[_toolbar items] enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
			if (((NSToolbarItem *)object).tag > [pane.tag unsignedIntegerValue]) insertIndex = index, *stop = YES;
		}];
		[_toolbar insertItemWithItemIdentifier:pane.identifier atIndex:insertIndex];
	}
	
	if ([_toolbarPanes count] > 0) {
		NSString *identifier = nil;
		if (delegate && [delegate respondsToSelector:@selector(toolbarDefaultSelectedItemIdentifier:)]) {
			identifier = [delegate toolbarDefaultSelectedItemIdentifier:_toolbar];
			if (!identifier || ![self toolbarPaneWithIdentifier:identifier]) {
				IFLog(@"Delegate responded with an invalid value (%@) for `toolbarDefaultSelectedItemIdentifier:`. Attempting default value (%@).", identifier, [_itemIdentifiers objectAtIndex:0]);
				identifier = nil;
			}
		}
		if (!identifier) identifier = [_itemIdentifiers objectAtIndex:0];
		
		[self selectToolbarItemWithIdentifier:identifier];
		
		if (delegate && [delegate respondsToSelector:@selector(toolbarShouldCenterToolbarItems:)] && [delegate toolbarShouldCenterToolbarItems:_toolbar]) {
			[_toolbar insertItemWithItemIdentifier:NSToolbarFlexibleSpaceItemIdentifier atIndex:0];
			[_toolbar insertItemWithItemIdentifier:NSToolbarFlexibleSpaceItemIdentifier atIndex:[[_toolbar items] count]];
		}
	} else {
		IFLog(@"No IFToolbarPanes found in %@.xib. Aborting.", _identifier);
	}
}

#pragma mark - Selection
- (IFToolbarPane *)selectedPane {
	for (IFToolbarPane *pane in _toolbarPanes) {
		if ([pane.tag unsignedIntegerValue] == _selectedTag) {
			return pane;
		}
	}
	
	IFLog(@"No pane currently selected!");
	return nil;
}

- (void)selectToolbarItem:(NSToolbarItem *)theItem {
	[self selectToolbarItemWithIdentifier:[theItem itemIdentifier]];
}

- (void)selectToolbarItemWithIdentifier:(NSString *)theIdentifier {
	if (!theIdentifier) {
		IFLog(@"Cannot select an item with a nil identifier. Aborting.");
		return;
	}
	
	if (![self toolbarPaneWithIdentifier:theIdentifier]) {
		IFLog(@"No toolbar item exists with the identifier '%@'. Aborting.", theIdentifier);
		return;
	}
	
	[_toolbar setSelectedItemIdentifier:theIdentifier];
	[[_toolbar valueForKey:@"_window"] setTitle:theIdentifier];
	[[_toolbar valueForKey:@"_window"] setContentViewWithResize:[[self toolbarPaneWithIdentifier:theIdentifier] view]];
	
	_selectedTag = [[self toolbarPaneWithIdentifier:theIdentifier].tag unsignedIntegerValue];
}

- (void)selectToolbarItemAtIndex:(NSUInteger)theIndex {
	NSArray *selectableIdentifiers = [self toolbarSelectableItemIdentifiers:_toolbar];
	if (theIndex >= [selectableIdentifiers count]) {
		IFLog(@"Selection index is not valid (%lu > %lu). Aborting.", theIndex, [selectableIdentifiers count]);
		return;
	}
	
	[self selectToolbarItemWithIdentifier:[selectableIdentifiers objectAtIndex:theIndex]];
}

- (IBAction)selectNextPane:(id)sender {
	NSUInteger selectedIndex = [_toolbarPanes indexOfObject:[self selectedPane]];
	if (selectedIndex < [_toolbarPanes count] - 1) {
		[self selectToolbarItemWithIdentifier:((IFToolbarPane *)[_toolbarPanes objectAtIndex:++selectedIndex]).identifier];
	}
}

- (IBAction)selectPreviousPane:(id)sender {
	NSUInteger selectedIndex = [_toolbarPanes indexOfObject:[self selectedPane]];
	if (selectedIndex > 0) {
		[self selectToolbarItemWithIdentifier:((IFToolbarPane *)[_toolbarPanes objectAtIndex:--selectedIndex]).identifier];
	}
}

- (IFToolbarPane *)toolbarPaneWithIdentifier:(NSString *)theIdentifier {
	__block IFToolbarPane *pane = nil;
	[_toolbarPanes enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
		if ([[((IFToolbarPane *)object) identifier] isEqualToString:theIdentifier]) pane = object, *stop = YES;
	}];
	
	return pane;
}

#pragma mark - Delegate Methods
- (void)setDelegate:(id <IFToolbarManagerDelegate>)theDelegate {
#if __has_feature(objc_arc)
	_delegate = theDelegate;
#else
	[_delegateReference release];
	_delegateReference = [[MAZeroingWeakRef alloc] initWithTarget:theDelegate];
#endif
}

- (id)delegate {
#if __has_feature(objc_arc)
	return _delegate;
#else
	return [_delegateReference target];
#endif
}

#pragma mark - NSToolbarDelegate Methods
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
	if (![toolbar isEqual:_toolbar]) return nil;
	
	NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	if ([itemIdentifier isEqualToString:NSToolbarSeparatorItemIdentifier] || [itemIdentifier isEqualToString:NSToolbarSpaceItemIdentifier] || [itemIdentifier isEqualToString:NSToolbarFlexibleSpaceItemIdentifier]) {
#if __has_feature(objc_arc)
		return item;
#else
		return [item autorelease];
#endif
	}
	[item setTarget:self];
	[item setAction:@selector(selectToolbarItem:)];
	[item setTag:[[self toolbarPaneWithIdentifier:itemIdentifier].tag unsignedIntegerValue]];
	[item setAutovalidates:YES];
	
#if __has_feature(objc_arc)
	id <IFToolbarManagerDelegate> delegate = _delegate;
#else
	id <IFToolbarManagerDelegate> delegate = [_delegateReference target];
#endif
	NSString *label = nil;
	if (delegate && [delegate respondsToSelector:@selector(toolbar:labelForItemWithIdentifier:)]) {
		label = [delegate toolbar:_toolbar labelForItemWithIdentifier:itemIdentifier];
		if (!label) {
			IFLog(@"Delegate responded with an invalid value (%@) for `toolbar:labelForItemWithIdentifier`. Attempting with default value (%@).", label, itemIdentifier);
			label = nil;
		}
	}
	if (!label) label = itemIdentifier;
	
	[item setLabel:label];
	[item setPaletteLabel:label];
	
	NSImage *image = nil;
	if (delegate && [delegate respondsToSelector:@selector(toolbar:imageForItemWithIdentifier:)]) {
		image = [delegate toolbar:_toolbar imageForItemWithIdentifier:itemIdentifier];
		if (!image) {
			IFLog(@"Delegate responded with an invalid value (%@) for `toolbar:imageForItemWithIdentifier:`. Attempting with default value (%@).", image, [NSImage imageNamed:itemIdentifier]);
			image = nil;
		}
	}
	if (!image) image = [NSImage imageNamed:itemIdentifier];
	
	[item setImage:image];
#if __has_feature(objc_arc)
	return item;
#else
	return [item autorelease];
#endif
}

- (void)toolbarWillAddItem:(NSNotification *)notification {
	[_itemIdentifiers addObject:[[[notification userInfo] objectForKey:@"item"] itemIdentifier]];
}

- (void)toolbarDidRemoveItem:(NSNotification *)notification {
	[_itemIdentifiers removeObject:[[[notification userInfo] objectForKey:@"item"] itemIdentifier]];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
	return _itemIdentifiers;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
	return _itemIdentifiers;
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
	return [_itemIdentifiers objectsAtIndexes:[_itemIdentifiers indexesOfObjectsPassingTest:^(id object, NSUInteger index, BOOL *stop) {
		NSString *identifier = (NSString *)object;
		return (BOOL)(![identifier isEqualToString:NSToolbarSeparatorItemIdentifier] && ![identifier isEqualToString:NSToolbarSpaceItemIdentifier] && ![identifier isEqualToString:NSToolbarFlexibleSpaceItemIdentifier]);
	}]];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem {
#if __has_feature(objc_arc)
	id <IFToolbarManagerDelegate> delegate = _delegate;
#else
	id <IFToolbarManagerDelegate> delegate = [_delegateReference target];
#endif
	if (delegate && [delegate respondsToSelector:@selector(toolbar:shouldValidateItem:)] && ![delegate toolbar:_toolbar shouldValidateItem:theItem]) return NO;
	return !![self toolbarPaneWithIdentifier:[theItem itemIdentifier]];
}

#pragma mark - Description
- (NSString *)description {
	return [NSString stringWithFormat:@"<IFToolbarManager identifier=\"%@\"; toolbar=\"%@\"; selectedTag=%lu>", _identifier, _toolbar, _selectedTag];
}

@end