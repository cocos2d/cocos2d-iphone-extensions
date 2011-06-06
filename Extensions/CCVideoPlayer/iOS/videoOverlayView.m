//
//  videoOverlayView.m
//  iTraceur
//
//  Created by iPsi on 6/12/10.
//  Copyright 2010 Company/School. All rights reserved.
//
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#import "videoOverlayView.h"
#import "VideoPlayer.h"


@implementation VideoOverlayView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        
        //self.alpha = 0.0f;
        self.backgroundColor = [UIColor colorWithRed:0.0f green: 0.0f blue: 0.0f alpha: 0.0f];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touch = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( _touch )
    {
        // stop video
        [VideoPlayer cancelPlaying];
    }
    _touch = NO;
}


- (void)dealloc {
    [super dealloc];
}


@end

#endif
