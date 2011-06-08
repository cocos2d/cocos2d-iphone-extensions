CCSlider
==================

"I wanted to add a little slider control to allow the user to set the background music level in a game I am working on. 
So I created this little CCSliderControl class that I think is cute and useful." - Israel Roth, http://srooltheknife.blogspot.com/

CCSliderControl to CCSlider:

1. Added Mac Support
2. No hardcoded behavior now: CCSprite as background and CCMenuItem as thumb are used now at init.


How to create (Easy)
------------------------

        _musicSlider = 
		[CCSlider sliderWithBackgroundFile: @"optionsSliderBG.png"
							     thumbFile: @"optionsSliderThumb.png"];
		
		_musicSlider.tag = kMusicSliderTag;
		[self addChild:_musicSlider];
		_musicSlider.delegate = self;


How to create (Advanced)
------------------------

		CCMenuItemSprite *thumb1 = [CCMenuItemSprite itemFromNormalSprite: thumb1Button 
														   selectedSprite: thumb1ButtonSelected];
		
		_musicSlider = 
		[CCSlider sliderWithBackgroundSprite: [CCSprite spriteWithSpriteFrameName:@"iTraceurOptionsSliderBG.png"] 
							   thumbMenuItem: thumb1];
		
		_musicSlider.tag = kMusicSliderTag;
		[self addChild:_musicSlider];
		_musicSlider.delegate = self;
		
		
How to handle value changes
-------------

	- (void) valueChanged: (float) value tag: (int) tag; 
	{
		// range sentinel
		value = MIN(value, 1.0f);
		value = MAX(value, 0.0f);
		
		// set value * 100
		switch (tag) {
			case kMusicSliderTag:
				[[GameDirector sharedGameDirector] setMusicVolume: value * 100];
				break;
			case kSoundSliderTag:
				[[GameDirector sharedGameDirector] setSoundVolume: value * 100];
				break;
			default:
				break;
		}
	}