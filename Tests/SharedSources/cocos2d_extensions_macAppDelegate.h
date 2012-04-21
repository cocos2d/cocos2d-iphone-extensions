//
//  cocos2d_extensions_macAppDelegate.h
//  cocos2d-extensions-mac
//
//  Created by Stepan Generalov on 06.06.11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "cocos2d.h"

static NSString *appDelegateToggleFullscreenNotification = @"fullscreenToggled";

@interface cocos2d_extensions_macAppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow	*window_;
	CCGLView	*glView_;
}

@property (assign) IBOutlet NSWindow	*window;
@property (assign) IBOutlet CCGLView	*glView;

- (IBAction)toggleFullScreen:(id)sender;

@end
