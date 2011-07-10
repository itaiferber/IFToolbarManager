//
//  MAZeroingWeakRef.h
//  ZeroingWeakRef
//
//  Created by Michael Ash on 7/5/10.
//

#import <Cocoa/Cocoa.h>

/*
 Copyright (c) 2010, Michael Ash
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 
 Neither the name of Michael Ash nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

@interface MAZeroingWeakRef : NSObject
{
    id _target;
#if NS_BLOCKS_AVAILABLE
    void (^_cleanupBlock)(id target);
#endif
}

+ (BOOL)canRefCoreFoundationObjects;

+ (id)refWithTarget: (id)target;

- (id)initWithTarget: (id)target;

#if NS_BLOCKS_AVAILABLE
// cleanup block runs while the global ZWR lock is held
// so make it short and sweet!
// use GCD or something to schedule execution later
// if you need to do something that may take a while
//
// it is unsafe to call -target on the weak ref from
// inside the cleanup block, which is why the target
// is passed in as a parameter
// note that you must not resurrect the target at this point!
- (void)setCleanupBlock: (void (^)(id target))block;
#endif

- (id)target;

@end
