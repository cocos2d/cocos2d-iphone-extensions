Cocos2d Extensions
=================
This repo is a collection of different 3rd party extensions for the Cocos2d-iPhone Engine.

How to get the source
=================
While gh-pages is main branch you need to execute this, to clone the repo and get to the extensions source: 

```
    git clone git@github.com:cocos2d/cocos2d-iphone-extensions.git
    cd cocos2d-iphone-extensions
    git fetch origin
    git checkout -t origin/develop
    git submodule update --init
```

Files & Folders
=================
* **cocos2d** - cocos2d-iphone submodule.
* **Extensions** - folders with extensions sources, that can be inlcuded in your project.
* **Tests** - sources & resources of Extensions demos.
   * **SharedResources** - resources shared between all tests (icons, fps images, etc...)
   * **SharedSources** - sources shared between all tests (appDelegates, pch's, etc...)
* **cocos2d-extensions-ios.xcodeproj** - XCode Project containing all extensions and their demos/tests for iOS Platform.
* **cocos2d-extensions-mac.xcodeproj** - XCode Project containing all extensions and their demos/tests for Mac OS X Platform.

Extensions
=================
 * [iOS/Mac] **CCMenuAdvanced** - CCMenu subclass with additional features: relativeAnchor, more align options, priority property, scrolling with swipe/trackpad/mousewheel
 * [iOS/Mac] **CCMenuItemSpriteIndependent** - CCMenuItemSprite Subclass, that doesnt add normal/selected/disabled images (sprites) as children. It retains them and delegates rect & convertToNodeSpace: methods to normalImage_. So it's possible to use CCSpriteBatchNode & add position sprites of menuItem anyway you want.
 * *...*
