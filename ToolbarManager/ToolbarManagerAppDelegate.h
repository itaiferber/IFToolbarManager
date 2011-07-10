//
//  ToolbarManagerAppDelegate.h
//  ToolbarManager
//
//  Created by Itai Ferber on 7/8/11.
//  Copyright 2011 Itai Ferber. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IFToolbarManager.h"

@interface ToolbarManagerAppDelegate : NSObject <NSApplicationDelegate, IFToolbarManagerDelegate> {
	NSWindow *_window;
	NSToolbar *_toolbar;
	IFToolbarManager *_manager;
}

@property (strong) IBOutlet NSWindow *window;

@end
