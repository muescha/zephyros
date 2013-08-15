//
//  SDScreenClientProxy.m
//  Zephyros
//
//  Created by Steven Degutis on 8/12/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDScreenClientProxy.h"

#import "SDGeometry.h"
#import "SDLogWindowController.h"

@implementation SDScreenClientProxy

- (id) frame_including_dock_and_menu:(NSArray*)args msgID:(id)msgID {
    return SDDictFromRect([self.receiver frameIncludingDockAndMenu]);
}

- (id) frame_without_dock_or_menu:(NSArray*)args msgID:(id)msgID {
    return SDDictFromRect([self.receiver frameWithoutDockOrMenu]);
}

- (id) next_screen:(NSArray*)args msgID:(id)msgID {
    return [self.receiver nextScreen];
}

- (id) previous_screen:(NSArray*)args msgID:(id)msgID {
    return [self.receiver previousScreen];
}

- (id) rotate_to:(NSArray*)args msgID:(id)msgID {
    SDTypeCheckArg(NSNumber, degrees, 0);
    
    int deg = [degrees intValue];
    if (deg == 0 || deg == 90 || deg == 180 || deg == 270) {
        [self.receiver rotateTo: deg];
    }
    else {
        SDLogError(@"Error: Rotation must be to either 0, 90, 180, or 270 degrees. Got: %d", deg);
    }
    
    return nil;
}

@end
