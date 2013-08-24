//
//  SDModifierKeysListener.m
//  Zephyros
//
//  Created by Steven on 8/24/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDModifierKeysListener.h"

#import "SDAppStalker.h"

@interface SDModifierKeysListener ()
@property BOOL isListening;
@end

@implementation SDModifierKeysListener

+ (SDModifierKeysListener*) sharedListener {
    static SDModifierKeysListener* sharedListener;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedListener = [[SDModifierKeysListener alloc] init];
    });
    return sharedListener;
}

- (void) startListening {
    if (self.isListening)
        return;
    
    self.isListening = YES;
    
    CFMachPortRef p = CGEventTapCreate(kCGHIDEventTap,
                                       kCGHeadInsertEventTap,
                                       kCGEventTapOptionListenOnly,
                                       CGEventMaskBit(kCGEventFlagsChanged),
                                       &callbackFunction,
                                       NULL);
    CFRunLoopSourceRef s = CFMachPortCreateRunLoopSource(NULL, p, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), s, kCFRunLoopCommonModes);
}

static CGEventRef callbackFunction(CGEventTapProxy proxy,
                                   CGEventType type,
                                   CGEventRef event,
                                   void *userInfo)
{
    CGEventFlags curAltkey = CGEventGetFlags(event);
    
    NSMutableArray* mods = [NSMutableArray arrayWithCapacity:5];
    if (curAltkey & kCGEventFlagMaskAlternate) [mods addObject:@"ALT"];
    if (curAltkey & kCGEventFlagMaskShift) [mods addObject:@"SHIFT"];
    if (curAltkey & kCGEventFlagMaskControl) [mods addObject:@"CTRL"];
    if (curAltkey & kCGEventFlagMaskCommand) [mods addObject:@"CMD"];
    if (curAltkey & kCGEventFlagMaskSecondaryFn) [mods addObject:@"FN"];
    
    NSNotification* note = [NSNotification notificationWithName:SDListenEventModifiersChanged
                                                         object:nil
                                                       userInfo:@{@"thing": mods}];
    
    [[NSNotificationCenter defaultCenter] postNotification:note];
    
    return event;
}

@end
