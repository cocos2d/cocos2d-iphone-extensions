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

#import "CCSendMessages.h"


@implementation CCSendMessages

+ (id)actionWithTarget:(id)t {
	return [[[self alloc] initWithTarget:t] autorelease];
}

- (id)initWithTarget:(id)t {
    
    self = [super init];
    if ( self ) {
		
		if (!t)
		{
			CCLOGERROR(@"CCSendMessages#initWithTarget: target must not be nil!");
			
			[self release];
			return nil;
		}
        
        messagesTarget_ = [t retain];
        messages_ = [[CCStoredMessages alloc] init];
		messages_->target_ = t;
        
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
	
	CCSendMessages *copy = [[CCSendMessages allocWithZone:zone] initWithTarget:messagesTarget_];
	for (NSInvocation *invocation in messages_->invocations_)
		[copy addInvocation:invocation];
	return copy;
	
}

- (void)dealloc {
    
    [messagesTarget_ release];
    [messages_ release];
    [super dealloc];
	
}

- (id)addMessage {
    
	return messages_;
	
}

- (void)addInvocation:(NSInvocation *)invocation {
	
	if (messages_ != nil) {
		
		if ( ![invocation argumentsRetained] ) {
			// Target is set to nil to prevent retain loops that could
			// occur due to [NSInvocation retainArguments]
			[invocation setTarget:nil];
			
			[invocation retainArguments];
		}
		
		[messages_->invocations_ addObject:invocation];
	}
	
}

- (void)startWithTarget:(id)target {
	
	[super startWithTarget:target];
	[self execute];
	
}

- (void)execute {
	
	for (NSInvocation *invocation in messages_->invocations_) {
		[invocation invokeWithTarget:messagesTarget_];
	}
	
}

@end



@implementation CCStoredMessages

- (id)init {
	
	self = [super init];
	if ( self ) {
		
		invocations_ = [[NSMutableArray alloc] init];
		
	}
	return self;
	
}

- (void)dealloc {
	
	[invocations_ release];
	[super dealloc];
	
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	
	NSMethodSignature *retVal = [super methodSignatureForSelector:aSelector];
	
	if ( !retVal ) {
		retVal = [target_ methodSignatureForSelector:aSelector];
	}
	
	return retVal;
	
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	
	[invocations_ addObject:anInvocation];
	
	if ( ![anInvocation argumentsRetained] ) {
		// Target is set to nil to prevent retain loops that could
		// occur due to [NSInvocation retainArguments]
		[anInvocation setTarget:nil];
		
		[anInvocation retainArguments];
	}
	
}

@end
