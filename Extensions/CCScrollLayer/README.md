
CCScrollLayer
=============

Readme by Giv Parvaneh ( @givp )   
http://www.givp.org/blog/2010/12/30/scrolling-menus-in-cocos2d/

This class was originally written by DK101   
http://dk101.net/2010/11/30/implementing-page-scrolling-in-cocos2d/

It is a very clean and elegant subclass of CCLayer that lets you pass-in an array of layers and it will then create a smooth scroller.   
Complete with the "snapping" effect. You can create screens with anything that can be added to a CCLayer.   
Also there's an option to change the width of each layer for the "Angry Birds" style preview effect.
(In a fact layer contentSize isn't changed, but widthOffset is used for pages (CCLayer) positioning inside the CCScrollLayer)


Usage
=============

1. add both files to your project
2. in your scene import CCScrollLayer.h
3. in your scene's init method construct each layer and pass it to the CCScrollLayer class (See CCScrollLayerTestLayer.m for details).

Additions since Giv Parvaneh version
=====================================

1. Added ability to swipe above targetedTouchDelegates.
2. Added touches lengths & screens properties.
3. Added factory class method.
4. Code cleanup.
5. Added current page number indicator (iOS Style Dots) with positioning.
6. moveToPage is public method.
7. Standard pages numbering starting from zero: [0;totalScreens-1] instead of [1; totalScreens]
 
Limitations
=============

1. Currently only iOS is supported. Implement ccMouseDelegate and/or ccKeyboardDelegate & remove #ifdef wrappers to add Mac OS X support.
2. Standard Touch Delegates will still receive touch events after layer starts sliding.


