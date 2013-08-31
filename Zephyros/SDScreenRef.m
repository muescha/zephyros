//
//  SDScreenClientProxy.m
//  Zephyros
//
//  Created by Steven Degutis on 8/12/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDScreenRef.h"

#import "SDGeometry.h"
#import "SDLogWindowController.h"

#import "SDScreenRef.h"

#import "SDAppStalker.h"

@interface SDScreenRef ()

@property (copy) void(^deathCallback)();

@end

@implementation SDScreenRef

- (void) whenDead:(void(^)())block {
    self.deathCallback = block;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screensChanged:) name:SDListenEventScreensChanged object:nil];
}

- (void) screensChanged:(NSNotification*)note {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.deathCallback();
    self.deathCallback = nil;
}

- (id) frame_including_dock_and_menu:(NSArray*)args msgID:(id)msgID {
    return SDDictFromRect([self.resource frameIncludingDockAndMenu]);
}

- (id) frame_without_dock_or_menu:(NSArray*)args msgID:(id)msgID {
    return SDDictFromRect([self.resource frameWithoutDockOrMenu]);
}

- (id) next_screen:(NSArray*)args msgID:(id)msgID {
    return [self.client store: [SDScreenRef withResource: [self.resource nextScreen]]];
}

- (id) previous_screen:(NSArray*)args msgID:(id)msgID {
    return [self.client store: [SDScreenRef withResource: [self.resource previousScreen]]];
}

- (id) rotate_to:(NSArray*)args msgID:(id)msgID {
    SDTypeCheckArg(NSNumber, degrees, 0);
    
    int deg = [degrees intValue];
    if (deg == 0 || deg == 90 || deg == 180 || deg == 270) {
        [self.resource rotateTo: deg];
    }
    else {
        SDLogError(@"Error: Rotation must be to either 0, 90, 180, or 270 degrees. Got: %d", deg);
    }
    
    return [NSNull null];
}

@end
