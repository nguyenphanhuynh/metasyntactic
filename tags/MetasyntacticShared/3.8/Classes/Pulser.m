// Copyright 2008 Cyrus Najmabadi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "Pulser.h"

@interface Pulser()
@property (retain) id target;
@property SEL action;
@property NSTimeInterval pulseInterval;
@property (retain) NSDate* lastPulseTime;
@end


@implementation Pulser

@synthesize target;
@synthesize action;
@synthesize pulseInterval;
@synthesize lastPulseTime;

- (void) dealloc {
    self.target = nil;
    self.action = nil;
    self.pulseInterval = 0;
    self.lastPulseTime = nil;

    [super dealloc];
}


- (id) initWithTarget:(id) target__
               action:(SEL) action__
        pulseInterval:(NSTimeInterval) pulseInterval__ {
    if ((self = [super init])) {
        self.target = target__;
        self.action = action__;
        self.pulseInterval = pulseInterval__;
        self.lastPulseTime = [NSDate dateWithTimeIntervalSince1970:1];
    }

    return self;
}


+ (Pulser*) pulserWithTarget:(id) target
                      action:(SEL) action
               pulseInterval:(NSTimeInterval) pulseInterval {
    return [[[Pulser alloc] initWithTarget:target
                                    action:action
                             pulseInterval:pulseInterval] autorelease];
}


- (void) tryPulse:(NSDate*) date {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(tryPulse:) withObject:date waitUntilDone:NO];
        return;
    }

    if ([date compare:lastPulseTime] == NSOrderedAscending) {
        // we sent out a pulse after this one.  just disregard this pulse
        //NSLog(@"Pulse at '%@' < last pulse at '%@'.  Disregarding.", date, lastPulseTime);
        return;
    }

    NSDate* now = [NSDate date];
    NSDate* nextViablePulseTime = [lastPulseTime addTimeInterval:pulseInterval];
    if ([now compare:nextViablePulseTime] == NSOrderedAscending) {
        // too soon since the last pulse.  wait until later.
        //NSLog(@"Pulse at '%@' too soon since last pulse at '%@'.  Will perform later.", date, lastPulseTime);
        NSTimeInterval waitTime = ABS([date timeIntervalSinceDate:nextViablePulseTime]) + 1;
        waitTime = MIN(waitTime, pulseInterval);
        [self performSelector:@selector(tryPulse:) withObject:date afterDelay:waitTime];
        return;
    }

    // ok, actually pulse.
    self.lastPulseTime = now;
    //NSLog(@"Pulse at '%@' being performed at '%@'.", date, lastPulseTime);
    [target performSelectorOnMainThread:action withObject:nil waitUntilDone:NO];
}


- (void) forcePulse {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(forcePulse) withObject:nil waitUntilDone:NO];
        return;
    }

    self.lastPulseTime = [NSDate date];
    //NSLog(@"Forced pulse at '%@'.", lastPulseTime);
    [target performSelector:action];
}


- (void) tryPulse {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(tryPulse) withObject:nil waitUntilDone:NO];
        return;
    }

    [self tryPulse:[NSDate date]];
}

@end
