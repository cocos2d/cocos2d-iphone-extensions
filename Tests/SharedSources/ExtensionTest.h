/*
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2011 Stepan Generalov
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "cocos2d.h"

#define SYNTHESIZE_EXTENSION_TEST(TEST_LAYER)	\
												\
@implementation ExtensionTest					\
												\
+(CCScene *) scene								\
{												\
	CCScene *scene = [CCScene node];			\
	[scene addChild: [TEST_LAYER node]];		\
	return scene;								\
}												\
												\
+ (BOOL) isRetinaDisplaySupported				\
{												\
	return YES;									\
}												\
												\
@end											\

#define SYNTHESIZE_EXTENSION_TEST_WITHOUT_RETINA(TEST_LAYER)	\
																\
@implementation ExtensionTest									\
																\
+(CCScene *) scene												\
{																\
	CCScene *scene = [CCScene node];							\
	[scene addChild: [TEST_LAYER node]];						\
	return scene;												\
}																\
																\
+(BOOL) isRetinaDisplaySupported								\
{																\
	return NO;													\
}																\
																\
@end															\

// ExtensionTest - Interface
// Implementation differs in different ExtensionTests
@interface ExtensionTest : CCLayer
{
}

// Returns a CCScene that contains the test layer. 
+(CCScene *) scene;

+(BOOL) isRetinaDisplaySupported;

@end
