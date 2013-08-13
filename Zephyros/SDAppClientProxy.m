//
//  SDAppClientProxy.m
//  Zephyros
//
//  Created by Steven Degutis on 8/12/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDAppClientProxy.h"

@implementation SDAppClientProxy

- (id) all_windows:(NSArray*)args msgID:(id)msgID {
    return [self.receiver allWindows];
}

- (id) visible_windows:(NSArray*)args msgID:(id)msgID {
    return [self.receiver visibleWindows];
}

- (id) title:(NSArray*)args msgID:(id)msgID {
    return [self.receiver title];
}

- (id) hidden_q:(NSArray*)args msgID:(id)msgID {
    return @([self.receiver isHidden]);
}

- (id) show:(NSArray*)args msgID:(id)msgID {
    [self.receiver show];
    return nil;
}

- (id) hide:(NSArray*)args msgID:(id)msgID {
    [self.receiver hide];
    return nil;
}

- (id) kill:(NSArray*)args msgID:(id)msgID {
    [self.receiver kill];
    return nil;
}

- (id) kill9:(NSArray*)args msgID:(id)msgID {
    [self.receiver kill9];
    return nil;
}

@end
