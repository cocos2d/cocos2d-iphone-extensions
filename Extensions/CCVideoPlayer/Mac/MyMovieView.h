//
//  MyMovieView.h
//  ViewController
//
//  Created by Stepan Generalov on 06.01.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED

#import <Cocoa/Cocoa.h>
#import "QTKit/QTKit.h"
#import "CCEventDispatcher.h"

@interface MyMovieView : QTMovieView <CCKeyboardEventDelegate> 
{}

@end

#endif
