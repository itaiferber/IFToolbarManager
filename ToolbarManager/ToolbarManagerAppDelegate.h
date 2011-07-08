//
//  ToolbarManagerAppDelegate.h
//  ToolbarManager
//
//  Created by Itai Ferber on 7/8/11.
//  Copyright 2011 Itai Ferber. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ToolbarManagerAppDelegate : NSObject <NSApplicationDelegate> {
	NSWindow *_window;
}

@property (strong) IBOutlet NSWindow *window;

@end
