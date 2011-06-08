CCSendMessages by Darren Clark
===============

CCSendMessages is a class meant to be a little more flexible than than the other CCActions that run functions. The main use of it for me is to remove the need to create one-line "wrapper" methods to call a function that doesn't have a message signature supported by the standard CCCallFunc.   
http://www.cocos2d-iphone.org/forum/topic/14468

Examples
===============

Basic usage:

```
   CCSendMessages *remove = [CCSendMessages actionWithTarget:someNode];  // Create object with a target (someNode)
   [[remove addMessage] removeFromParentAndCleanup:YES];  // queue removeFromParentAndCleanup: selector
   [someOtherNode runAction:remove];   // CCSendMessages will run removeFromParentAndCleanup: on its target (someNode)
   // even though we are running it on a different node (someOtherNode)
```

Works with standard C types, structures and objects:

```
   CCSendMessages *crazy = [CCSendMessages actionWithTarget:someNode];
   [[crazy addMessage] doSomethingWithInt:5 andPoint:ccp(0,8) andObject:@"Some string.."];
   [someOtherNode runAction:crazy];
```

Limitations
================

1. You cannot use this to call methods in the NSObject class or in the NSObject protocol. (for example, don't use this to call retain or release on an object!!)
1. The method you are calling must have a fixed number of arguments (no printf() style argument lists)