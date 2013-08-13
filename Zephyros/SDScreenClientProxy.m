//
//  SDScreenClientProxy.m
//  Zephyros
//
//  Created by Steven Degutis on 8/12/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDScreenClientProxy.h"

#import "SDGeometry.h"

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

@end
