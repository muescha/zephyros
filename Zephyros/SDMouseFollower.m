//
//  SDMouseFollower.m
//  Zephyros
//
//  Created by Steven on 8/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDMouseFollower.h"

#import "SDAppStalker.h"

@interface SDMouseFollower ()

@property BOOL isListening;
@property NSEvent* lastEvent;

@end

@implementation SDMouseFollower

+ (SDMouseFollower*) sharedFollower {
    static SDMouseFollower* sharedFollower;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFollower = [[SDMouseFollower alloc] init];
    });
    return sharedFollower;
}

- (void) startListening {
    if (self.isListening)
        return;
    
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(heartBeat:)
                                   userInfo:nil
                                    repeats:YES];
    
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSMouseMovedMask handler:^(NSEvent* event) { self.lastEvent = event; }];
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDraggedMask handler:^(NSEvent* event) { self.lastEvent = event; }];
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSRightMouseDraggedMask handler:^(NSEvent* event) { self.lastEvent = event; }];
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSOtherMouseDraggedMask handler:^(NSEvent* event) { self.lastEvent = event; }];
    
    self.isListening = YES;
}

- (void) heartBeat:(id)alwaysNil {
    if (self.lastEvent) {
        NSPoint p = [self.lastEvent locationInWindow];
        CGFloat deltaX = [self.lastEvent deltaX];
        CGFloat deltaY = [self.lastEvent deltaY];
        BOOL dragged = [self.lastEvent type] != NSMouseMoved;
        
        NSMutableDictionary* data = [@{
                                     @"x": @(p.x),
                                     @"y": @(p.y),
                                     @"deltaX": @(deltaX),
                                     @"deltaY": @(deltaY),
                                     @"dragged": @(dragged),
                                     } mutableCopy];
        
        if (dragged) {
            int which = 0;
            
            if ([self.lastEvent type] == NSLeftMouseDragged)
                which = -1;
            else if ([self.lastEvent type] == NSOtherMouseDragged)
                which = 0;
            else if ([self.lastEvent type] == NSRightMouseDragged)
                which = 1;
            
            [data setObject:@(which) forKey:@"whichButton"];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SDListenEventMouseMoved
                                                            object:nil
                                                          userInfo:@{@"thing": data}];
        
        self.lastEvent = nil;
    }
}

@end
