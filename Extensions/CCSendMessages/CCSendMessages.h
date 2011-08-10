/*
 * CCSendMessages
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2011 by Darren Clark
 * http://darrenclark.ca/
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

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class CCStoredMessages;

/** @class CCSendMessages CCActionInstant that sends messsages to a target when it is run.
 *
 * It is different than the CCCallFunc classes in that any message can be sent 
 * to a target regardless of the number/type of arguments.
 *
 * NOTE: Any selector in the NSObject class and any selector in the NSObject and
 * NSCopying protocals cannot be added via -addMessage.
 * If you need to call one of those selectors, create an NSInvocation and add it
 * via -addInvocation:.
 *
 * Usage: 
 *	Create a CCSendMessages instance with a target using -initWithTarget: or
 *	+actionWithTarget:
 *
 *	Add message call(s) to it:
 *		(assuming sendMessages is your CCSendMessages object)
 *		[[sendMessages addMessage] setOpacity:0.5];
 *		[[sendMessages addMessage] long:0.5 selector:obj example:ccp(3,3)];
 *
 *	Run it on a CCNode with -runAction:, or add it to a
 *	CCSequence to run it later on!
 *
 *	Also, arguments don't have to be Objective-C objects.
*/
@interface CCSendMessages : CCActionInstant {
    
@private
    id messagesTarget_;
    CCStoredMessages *messages_;
    
}

/** Creates CCSendMessages action with given target. @see initWithTarget: */
+ (id)actionWithTarget:(id)t;

/** Init CCSendMessages action with given target
 * @param t Target, which will receive messages.
 */
- (id)initWithTarget:(id)t;

/** Returns CCStoredMessages that is stored internally to capture Objective-C messages. */
- (id)addMessage;

/** Adds NSInvocation to internal CCStoredMessages, use this method to send NSObject 
 * & NSCopying selectors to a target.
 */
- (void)addInvocation:(NSInvocation *)invocation;

/** Sends all captured messages to a target. 
 *
 * You don't need to use this method directly - use CCNode#runAction: instead.
 */
- (void)execute;

@end


// CCStoredMessages
// Simply a class to capture messages sent to it
//
// Public ivars are used instead of properties so
// that a wider range of selectors can be used
// (because this class cannot capture selectors it 
// responds to).  Also, because of this, most logic
// is handled in CCSendMessages

@interface CCStoredMessages : NSObject {

@public
	id target_;
    NSMutableArray *invocations_;

}

@end