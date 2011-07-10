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
- (void)loadPanes;
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
		_toolbar = [theToolbar retain];
		[_toolbar setDelegate:self];
		_selectedTag = 0;
		_itemIdentifiers = [[NSMutableArray alloc] init];
		_toolbarPanes = [[NSMutableArray alloc] init];
		_delegateReference = nil;
		
		[self loadPanes];
	}
	
	return self;
}

- (id)initWithToolbar:(NSToolbar *)theToolbar identifier:(NSString *)theIdentifier {
	if (!theToolbar) return nil;
	if ((self = [super init])) {
		_identifier = theIdentifier ? [theIdentifier copy] : [[theToolbar identifier] copy];
		_toolbar = [theToolbar retain];
		[_toolbar setDelegate:self];
		_selectedTag = 0;
		_itemIdentifiers = [[NSMutableArray alloc] init];
		_toolbarPanes = [[NSMutableArray alloc] init];
		_delegateReference = nil;
		
		[self loadPanes];
	}
	
	return self;
}

- (id)initWithToolbar:(NSToolbar *)theToolbar identifier:(NSString *)theIdentifier delegate:(id <IFToolbarManagerDelegate>)theDelegate {
	if (!theToolbar) return nil;
	if ((self = [super init])) {
		_identifier = theIdentifier ? [theIdentifier copy] : [[theToolbar identifier] copy];
		_toolbar = [theToolbar retain];
		[_toolbar setDelegate:self];
		_selectedTag = 0;
		_itemIdentifiers = [[NSMutableArray alloc] init];
		_toolbarPanes = [[NSMutableArray alloc] init];
		_delegateReference = [[MAZeroingWeakRef alloc] initWithTarget:theDelegate];
		
		[self loadPanes];
	}
	
	return self;
}

#pragma mark - Deallocation
- (void)dealloc {
	[_identifier release], _identifier = nil;
	[_toolbar release], _toolbar = nil;
	[_itemIdentifiers release], _itemIdentifiers = nil;
	[_toolbarPanes release], _toolbarPanes = nil;
	[_delegateReference release];
	[super dealloc];
}

#pragma mark - Loading
- (void)loadPanes {
	id <IFToolbarManagerDelegate> delegate = [_delegateReference target];
	NSString *path = nil;
	if (delegate && [delegate respondsToSelector:@selector(toolbarAssociatedXibName:)]) {
		path = [delegate toolbarAssociatedXibName:_toolbar];
		if (![[NSBundle mainBundle] pathForResource:path ofType:@"nib"]) {
			IFLog(@"Delegate responded with an invalid value (%@) for `toolbarAssociatedXibName:`. Attempting default value (%@).", path, _identifier);
			path = _identifier;
		}
	} else {
		path = _identifier;
	}
	
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
				identifier = [_itemIdentifiers objectAtIndex:0];
			}
		} else {
			identifier = [_itemIdentifiers objectAtIndex:0];
		}
		
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
	[_delegateReference release];
	_delegateReference = [[MAZeroingWeakRef alloc] initWithTarget:theDelegate];
}

- (id)delegate {
	return [_delegateReference target];
}

#pragma mark - NSToolbarDelegate Methods
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
	if (![toolbar isEqual:_toolbar]) return nil;
	
	NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
	if ([itemIdentifier isEqualToString:NSToolbarSeparatorItemIdentifier] || [itemIdentifier isEqualToString:NSToolbarSpaceItemIdentifier] || [itemIdentifier isEqualToString:NSToolbarFlexibleSpaceItemIdentifier]) return item;
	[item setTarget:self];
	[item setAction:@selector(selectToolbarItem:)];
	[item setTag:[[self toolbarPaneWithIdentifier:itemIdentifier].tag unsignedIntegerValue]];
	[item setAutovalidates:YES];
	
	id <IFToolbarManagerDelegate> delegate = [_delegateReference target];
	NSString *label = nil;
	if (delegate && [delegate respondsToSelector:@selector(toolbar:labelForItemWithIdentifier:)]) {
		label = [delegate toolbar:_toolbar labelForItemWithIdentifier:itemIdentifier];
		if (!label) {
			IFLog(@"Delegate responded with an invalid value (%@) for `toolbar:labelForItemWithIdentifier`. Attempting with default value (%@).", label, itemIdentifier);
			label = itemIdentifier;
		}
	} else {
		label = itemIdentifier;
	}
	[item setLabel:label];
	[item setPaletteLabel:label];
	
	NSImage *image = nil;
	if (delegate && [delegate respondsToSelector:@selector(toolbar:imageForItemWithIdentifier:)]) {
		image = [delegate toolbar:_toolbar imageForItemWithIdentifier:itemIdentifier];
		if (!image) {
			IFLog(@"Delegate responded with an invalid value (%@) for `toolbar:imageForItemWithIdentifier:`. Attempting with default value (%@).", image, [NSImage imageNamed:itemIdentifier]);
			image = [NSImage imageNamed:itemIdentifier];
		}
	} else {
		image = [NSImage imageNamed:itemIdentifier];
	}
	[item setImage:image];
	
	return item;
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
	return (BOOL)([self toolbarPaneWithIdentifier:[theItem itemIdentifier]]);
}

#pragma mark - Description
- (NSString *)description {
	return [NSString stringWithFormat:@"<IFToolbarManager identifier=\"%@\"; toolbar=\"%@\"; selectedTag=%lu>", _identifier, _toolbar, _selectedTag];
}

@end