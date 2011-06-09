//
//  iTraceurProgressBar.m
//  iTraceur - Parkour / Freerunning Platform Game
//
//  Created by Stepan Generalov on 03.03.11.
//  Copyright 2011 Parkour Games. All rights reserved.
//

#import "iTraceurProgressBar.h"


@implementation iTraceurProgressBar

+ (id) progressBar
{
	return [  [ [self alloc] init] autorelease  ];
}

- (id) init
{
	if ( (self = [super initWithFile:@"iTraceurProgressBar.png"]) )
	{
		self.type = kCCProgressTimerTypeHorizontalBarLR;
		
		
		CCSprite *background = [CCSprite spriteWithFile:@"iTraceurProgressBarBackground.png"];
		CCSprite *cover = [CCSprite spriteWithFile:@"iTraceurProgressBarCover.png"];
		
		background.anchorPoint = ccp(0,0);
		cover.anchorPoint = ccp(0,0);
		
		[self addChild: background z: -1];
		[self addChild: cover z: 2];
		
	}
	
	return self;
}

@end
