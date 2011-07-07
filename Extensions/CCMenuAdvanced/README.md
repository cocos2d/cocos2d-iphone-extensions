CCMenuAdvanced 
==================

CCMenuAdvanced is CCMenu with keyboard support for Mac (esc/arrows/enter), a little bit different alignment options,
and possibility to slide. Unlike original CCMenu it uses natural positioning system:isRelativeAnchorPoint is YES by
 default & contentSize depends on the children of the CCMenuAdvanced (set automatically at init & each align).

Short video demo: [CCMenuAdvanced.MOV](http://dl.getdropbox.com/u/1765875/CCMenuAdvanced.MOV "CCMenuAdvanced video demo")
Screenshots: [Wiki/Sreenshots](https://github.com/psineur/CCMenuAdvanced/wiki/Screenshots "Screenshots" )


Main features
-------------

* Selecting and activating CCMenuItems with Keyboard 
(by default next/prev bindings aren't set - set them manually or use one of align methods to bind arrows for this).
* One of CCMenuItems can be set as escapeDelegate - so it will be activated by pressing escape (useful for back/cancel button, this CCMenuItem escapeDelegate can be even child of other CCMenu)
* align left->right, right->left, bottom->top, top->bottom with autosetting self contentSize (useful with relativeAnchorPoint=YES to use menu as sprite, not strange-fullscreen-node)
* externalBoundsRect - if it is set then menu items will be scrollable inside these bounds.   
(boundaryRect is set in CCMenuAdvanced's parent coordinates)   
* priority property - for mouse and touch - must be set before onEnter to register with new priority
