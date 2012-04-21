/*
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2011-2012 Stepan Generalov
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "cocos2d_extensions_macAppDelegate.h"
#import "ExtensionTest.h"

#if COCOS2D_VERSION >= 0x00020000

@implementation MacGLView : CCGLView

- (NSString *) description
{
    return [NSString stringWithFormat:@"<%@:%@ = %08X>", [self class], [self superclass], self];
}

@end

#endif

@implementation cocos2d_extensions_macAppDelegate
@synthesize window=window_, glView=glView_;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	
    // Enable FPS and set OpenGL view in CCDirector.
#if COCOS2D_VERSION >= 0x00020000
    [director setDisplayStats:YES];
    [director setView:glView_];
#else
	[director setDisplayFPS:YES];	
	[director setOpenGLView:glView_];
#endif

	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	// Use kCCDirectorResize_NoScale if you don't want auto-scaling.
	[director setResizeMode:kCCDirectorResize_NoScale];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	// Start listening to resizeWindow notification
	[glView_ setPostsFrameChangedNotifications: YES];
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(updateForScreenReshape:) 
												 name: NSViewFrameDidChangeNotification 
											   object: glView_];
	
	
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
