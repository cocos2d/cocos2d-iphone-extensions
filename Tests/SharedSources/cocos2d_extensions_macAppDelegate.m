//
//  cocos2d_extensions_macAppDelegate.m
//  cocos2d-extensions-mac
//
//  Created by Stepan Generalov on 06.06.11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "cocos2d_extensions_macAppDelegate.h"
#import "ExtensionTest.h"

@implementation cocos2d_extensions_macAppDelegate
@synthesize window=window_, glView=glView_;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	
	// enable FPS and SPF
	[director setDisplayStats:YES];
	
	// connect the OpenGL view with the director
	[director setView:glView_];
	
	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	// Use kCCDirectorResize_NoScale if you don't want auto-scaling.
	[director setResizeMode:kCCDirectorResize_AutoScale];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	// Center main window
	[window_ center];
	
	// Start listening to resizeWindow notification
	[director.view setPostsFrameChangedNotifications: YES];
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(updateForScreenReshape:) 
												 name: NSViewFrameDidChangeNotification 
											   object: director.view];
	
	
	[director runWithScene:[ExtensionTest scene]];
}

- (void) updateForScreenReshape: (NSNotification *) aNotification
{
	CCScene *curScene = [[CCDirector sharedDirector] runningScene];
	
	if (curScene)
	{
		for (CCNode *child in curScene.children)
			if ([child respondsToSelector:@selector(updateForScreenReshape)])
				[child performSelector:@selector(updateForScreenReshape)];
	}
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (void)dealloc
{
	[[CCDirector sharedDirector] release];
	[window_ release];
	[super dealloc];
}

#pragma mark AppDelegate - IBActions

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:appDelegateToggleFullscreenNotification object: self];
}

@end
