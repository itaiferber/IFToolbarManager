//
//  ToolbarManagerAppDelegate.m
//  ToolbarManager
//
//  Created by Itai Ferber on 7/8/11.
//  Copyright 2011 Itai Ferber. All rights reserved.
//

#import "ToolbarManagerAppDelegate.h"

@implementation ToolbarManagerAppDelegate

#pragma mark - Synthesis
@synthesize window = _window;

#pragma mark - Awake from Nib
- (void)awakeFromNib {
	_toolbar = [[NSToolbar alloc] initWithIdentifier:@"Toolbar"];
	[_toolbar setAllowsUserCustomization:NO];
	[_window setToolbar:_toolbar];
	_manager = [[IFToolbarManager alloc] initWithToolbar:_toolbar];
	_manager.delegate = self;
	[_manager load];
}

#pragma mark - Deallocation
- (void)dealloc {
	[_manager release], _manager = nil;
	[_toolbar release], _toolbar = nil;
}

#pragma mark - Toolbar Customization Methods
- (BOOL)toolbarShouldCenterToolbarItems:(NSToolbar *)theToolbar {
	return YES;
}

@end