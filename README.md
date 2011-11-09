Cocos2d Extensions
=================
This repo is a collection of quality 3rd party extensions and additions for the Cocos2D-iPhone Engine.  
Everything that doesn’t modify Cocos2D itself, while bringing new functionality can become a part of Cocos2D-iPhone-Extensions Repo: alternative versions of existing classes, additional categories, new nodes, actions, etc…  

All extensions are well documented,shipped with testcases and are compatible with latest stable Cocos2D-iPhone version.  
With rare exceptions, they are designed for both Mac & iOS.
  
As well as Cocos2D, Cocos2D Extensions are licensed under the MIT License.

Cocos2D Extensions subforum: http://www.cocos2d-iphone.org/forum/forum/17  

Build & Runtime Requirements
====================

  * Mac OS X 10.6, Xcode 3.2.3 (or newer)
  * iOS 3.0 or newer for iOS games
  * Snow Leopard (v10.5) or newer for Mac games

How to get the source
===================== 

```
    git clone git@github.com:cocos2d/cocos2d-iphone-extensions.git
    cd cocos2d-iphone-extensions
	
	# init cocos2d-iphone submodule in order to build & run the tests.
    git submodule update --init
	
	# to get latest source from develop branch, use this command:
	git checkout -t origin/develop
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
 * [iOS/Mac] **CCVideoPlayer** - Simple Video Player for Cocos2D apps.
 * [iOS/Mac] **CCBigImage** - Dynamic Tiled Node for holding Large Images.
 * [iOS/Mac] **CCSlider** - Little Slider Control to allow the user to set the music/sfx/etc level in the range of 0.0f to 1.0f.
 * [iOS/Mac] **CCSendMessages** - CCActionInstant subclass, that is more flexible than other CCActions that run functions. Can be used in many cases as blocks replacement. 
 * [iOS/Mac] **CCScrollLayer** - CCLayer subclass that lets you pass-in an array of layers and it will then create a smooth scroller. Complete with the "snapping" effect.
 * [iOS/Mac] **FilesDownloader** - Downloader for a group of files with shared source path.
 * [iOS/Mac] **TMXGenerator** - Class that generates a single TMX map with multiple layers.
 * [iOS] **CCLayerPanZoom** - CCLayer subclass that can be scrolled and zoomed with one or two fingers (complete with rubber effect, two modes & ability to click through delegate).
 
 Video Overview and more Info can be found on the [Wiki](https://github.com/cocos2d/cocos2d-iphone-extensions/wiki "Wiki")   
 Detailed README for each extension is available in it's folder (i.e. Extensions/CCSlider/README.md).   
 On the GitHub it will be automatically shown under files list in the extension folder.
 
Building & Running Tests
=========================
Agregate target "BuildAllTests" will build all extensions tests - just set it as active target and change only active executable  to choose the test.   
Extension Test Template is used only as a template for new extensions test targets. It should not build, cause there's no ExtensionTest class implementation for this target.   
SYNTHESIZE_EXTENSION_TEST() macro is used (only once in each extension test) to implement ExtensionTest class, that creates scene with default extension test layer.
 
Contributing
================
Looking for Roadmap or TODO's? Check the [issues](https://github.com/cocos2d/cocos2d-iphone-extensions/issues "Issues") page.  
Want to share your own extension for cocos2d? Read this: [Adding-new-Extension](https://github.com/cocos2d/cocos2d-iphone-extensions/wiki/Adding-new-Extension)  
Know something that should be inlcuded in cocos2d-extensions-repo? Got problems and/or found a bug? [Create an Issue](https://github.com/cocos2d/cocos2d-iphone-extensions/issues/new "New Issue")
