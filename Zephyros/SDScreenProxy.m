//
//  NSScreenProxy.m
//  Zephyros
//
//  Created by Steven on 4/14/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDScreenProxy.h"

#import "SDGeometry.h"

@implementation SDScreenProxy

+ (SDScreenProxy*) mainScreen {
    SDScreenProxy* proxy = [[SDScreenProxy alloc] init];
    proxy.actualScreenObject = [NSScreen mainScreen];
    return proxy;
}

+ (NSArray*) allScreens {
    NSMutableArray* allScreens = [NSMutableArray array];
    for (NSScreen* screen in [NSScreen screens]) {
        SDScreenProxy* proxy = [[SDScreenProxy alloc] init];
        proxy.actualScreenObject = screen;
        [allScreens addObject:proxy];
    }
    return allScreens;
}

- (CGRect) frameIncludingDockAndMenu {
    NSScreen* primaryScreen = [[NSScreen screens] objectAtIndex:0];
    CGRect f = [self.actualScreenObject frame];
    f.origin.y = NSHeight([primaryScreen frame]) - NSHeight(f) - f.origin.y;
    return f;
}

- (CGRect) frameWithoutDockOrMenu {
    NSScreen* primaryScreen = [[NSScreen screens] objectAtIndex:0];
    CGRect f = [self.actualScreenObject visibleFrame];
    f.origin.y = NSHeight([primaryScreen frame]) - NSHeight(f) - f.origin.y;
    return f;
}

- (BOOL) rotateTo:(int)degrees {
    int rotation;
    
    if (degrees == 0)
        rotation = kIOScaleRotate0;
    else if (degrees == 90)
        rotation = kIOScaleRotate0;
    else if (degrees == 180)
        rotation = kIOScaleRotate0;
    else if (degrees == 270)
        rotation = kIOScaleRotate0;
    
    NSRect frame = [self.actualScreenObject frame];
    
    CGDirectDisplayID displays[50];
    CGDisplayCount displayCount;
    CGError err = CGGetDisplaysWithRect(frame, 50, displays, &displayCount);
    
    if (err != kCGErrorSuccess || displayCount != 1)
        return NO;
    
    io_service_t service = CGDisplayIOServicePort(displays[0]);
    IOOptionBits options = (0x00000400 | (rotation) << 16);
    IOServiceRequestProbe(service, options);
    
    return YES;
}

- (SDScreenProxy*) nextScreen {
    NSArray* screens = [SDScreenProxy allScreens];
    NSUInteger idx = [screens indexOfObject:self];
    
    idx += 1;
    if (idx == [screens count])
        idx = 0;
    
    return [screens objectAtIndex:idx];
}

- (SDScreenProxy*) previousScreen {
    NSArray* screens = [SDScreenProxy allScreens];
    NSUInteger idx = [screens indexOfObject:self];
    
    idx -= 1;
    if (idx == -1)
        idx = [screens count] - 1;
    
    return [screens objectAtIndex:idx];
}

// delegate equality to underlying NSScreens
// - maybe this is a terrible idea?

- (BOOL) isEqual:(SDScreenProxy*)object {
    return [self isKindOfClass:[object class]] && [self.actualScreenObject isEqual:object.actualScreenObject];
}

- (NSUInteger) hash {
    return [self.actualScreenObject hash];
}

@end
