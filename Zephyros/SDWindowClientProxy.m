//
//  SDWindowClientProxy.m
//  Zephyros
//
//  Created by Steven Degutis on 8/12/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDWindowClientProxy.h"

#import "SDGeometry.h"

@implementation SDWindowClientProxy

- (void) dealloc {
    [[self.client undoManager] removeAllActionsWithTarget:self];
    NSLog(@"bye");
}

- (id) title:(NSArray*)args msgID:(id)msgID {
    return [self.receiver title];
}

- (id) other_windows_on_same_screen:(NSArray*)args msgID:(id)msgID {
    return [self.receiver otherWindowsOnSameScreen];
}

- (id) other_windows_on_all_screens:(NSArray*)args msgID:(id)msgID {
    return [self.receiver otherWindowsOnAllScreens];
}

- (id) set_frame:(NSArray*)args msgID:(id)msgID {
    NSRect f = [self.receiver frame];
    [[self withUndo] set_frame:@[SDDictFromRect(f)]
                         msgID:msgID];
    
    SDTypeCheckArg(NSDictionary, frame, 0);
    [self.receiver setFrame: SDRectFromDict(frame)];
    return nil;
}

- (id) set_top_left:(NSArray*)args msgID:(id)msgID {
    NSPoint tl = [self.receiver topLeft];
    [[self withUndo] set_top_left:@[SDDictFromPoint(tl)]
                            msgID:msgID];
    
    SDTypeCheckArg(NSDictionary, top_left, 0);
    [self.receiver setTopLeft: SDPointFromDict(top_left)];
    return nil;
}

- (id) set_size:(NSArray*)args msgID:(id)msgID {
    NSSize s = [self.receiver size];
    [[self withUndo] set_size:@[SDDictFromSize(s)]
                        msgID:msgID];
    
    SDTypeCheckArg(NSDictionary, size, 0);
    [self.receiver setSize: SDSizeFromDict(size)];
    return nil;
}

- (id) frame:(NSArray*)args msgID:(id)msgID {
    return SDDictFromRect([self.receiver frame]);
}

- (id) top_left:(NSArray*)args msgID:(id)msgID {
    return SDDictFromPoint([self.receiver topLeft]);
}

- (id) size:(NSArray*)args msgID:(id)msgID {
    return SDDictFromSize([self.receiver size]);
}

- (id) maximize:(NSArray*)args msgID:(id)msgID {
    NSRect f = [self.receiver frame];
    [[self withUndo] set_frame:@[SDDictFromRect(f)]
                         msgID:msgID];
    
    [self.receiver maximize];
    return nil;
}

- (id) minimize:(NSArray*)args msgID:(id)msgID {
    [[self withUndo] un_minimize:@[]
                           msgID:msgID];
    
    [self.receiver minimize];
    return nil;
}

- (id) un_minimize:(NSArray*)args msgID:(id)msgID {
    [[self withUndo] minimize:@[]
                        msgID:msgID];
    
    [self.receiver unMinimize];
    return nil;
}

- (id) app:(NSArray*)args msgID:(id)msgID {
    return [self.receiver app];
}

- (id) screen:(NSArray*)args msgID:(id)msgID {
    return [self.receiver screen];
}

- (id) focus_window:(NSArray*)args msgID:(id)msgID {
//    [SDWindowProxy focusedWindow]
//    [[self withUndo] un_minimize:@[]
//                           msgID:msgID];
    
    return @([self.receiver focusWindow]);
}

- (id) windows_to_north:(NSArray*)args msgID:(id)msgID {
    return [self.receiver windowsToNorth];
}

- (id) windows_to_south:(NSArray*)args msgID:(id)msgID {
    return [self.receiver windowsToSouth];
}

- (id) windows_to_west:(NSArray*)args msgID:(id)msgID {
    return [self.receiver windowsToWest];
}

- (id) windows_to_east:(NSArray*)args msgID:(id)msgID {
    return [self.receiver windowsToEast];
}

- (id) focus_window_left:(NSArray*)args msgID:(id)msgID {
    [self.receiver focusWindowLeft];
    return nil;
}

- (id) focus_window_right:(NSArray*)args msgID:(id)msgID {
    [self.receiver focusWindowRight];
    return nil;
}

- (id) focus_window_up:(NSArray*)args msgID:(id)msgID {
    [self.receiver focusWindowUp];
    return nil;
}

- (id) focus_window_down:(NSArray*)args msgID:(id)msgID {
    [self.receiver focusWindowDown];
    return nil;
}

- (id) normal_window_q:(NSArray*)args msgID:(id)msgID {
    return @([self.receiver isNormalWindow]);
}

- (id) minimized_q:(NSArray*)args msgID:(id)msgID {
    return @([self.receiver isWindowMinimized]);
}

@end
