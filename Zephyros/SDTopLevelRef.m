//
//  SDTopLevelClientProxy.m
//  Zephyros
//
//  Created by Steven Degutis on 8/12/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDTopLevelRef.h"

#import "SDHotKey.h"
#import "SDEventListener.h"
#import "SDMouseFollower.h"
#import "SDModifierKeysListener.h"

#import "SDFuzzyMatcher.h"
#import "SDConfigLauncher.h"
#import "SDAlertWindowController.h"
#import "SDLogWindowController.h"
#import "SDBoxWindowController.h"

#import "SDWindow.h"

#import "SDWindowRef.h"
#import "SDScreenRef.h"
#import "SDAppRef.h"

#import "MACollectionUtilities.h"

@interface SDTopLevelRef ()

@property NSMutableArray* hotkeys;
@property NSMutableArray* listeners;

@end

@implementation SDTopLevelRef

- (id) init {
    if (self = [super init]) {
        self.hotkeys = [NSMutableArray array];
        self.listeners = [NSMutableArray array];
    }
    return self;
}

- (void) destroy {
//    NSLog(@"destrying bindings and listeners");
    
    for (SDHotKey* hotkey in self.hotkeys) {
        [hotkey unbind];
    }
    
    for (SDEventListener* listener in self.listeners) {
        [listener stopListening];
    }
}

- (id) undo:(NSArray*)args msgID:(id)msgID {
    [[self.client undoManager] undo];
    return [NSNull null];
}

- (id) redo:(NSArray*)args msgID:(id)msgID {
    [[self.client undoManager] redo];
    return [NSNull null];
}

- (id) bind:(NSArray*)args msgID:(id)msgID {
//    NSLog(@"binding");
    
    SDTypeCheckArg(NSString, key, 0);
    SDTypeCheckArrayArg(mods, NSString, 1);
    
    SDHotKey* hotkey = [[SDHotKey alloc] init];
    hotkey.key = [key uppercaseString];
    hotkey.modifiers = [mods valueForKeyPath:@"uppercaseString"];
    hotkey.fn = ^{
        [self.client sendResponse:[NSNull null] forID:msgID];
    };
    
    if ([hotkey bind]) {
        [self.hotkeys addObject:hotkey];
    }
    else {
        SDLogError(@"Can't bind: %@", [hotkey hotKeyDescription]);
    }
    
    return @-1;
}

- (id) unbind:(NSArray*)args msgID:(id)msgID {
    SDTypeCheckArg(NSString, key, 0);
    SDTypeCheckArrayArg(mods, NSString, 1);
    
    key = [key uppercaseString];
    NSArray* modifiers = [mods valueForKeyPath:@"uppercaseString"];
    
    SDHotKey* foundHotkey;
    for (SDHotKey* existingHotkey in self.hotkeys) {
        if ([existingHotkey.key isEqual: key] && [existingHotkey.modifiers isEqual: modifiers]) {
            foundHotkey = existingHotkey;
            break;
        }
    }
    
    if (foundHotkey) {
        [foundHotkey unbind];
        [self.hotkeys removeObject:foundHotkey];
        return @YES;
    }
    else {
        return @NO;
    }
}

- (id) listen:(NSArray*)args msgID:(id)msgID {
    SDTypeCheckArg(NSString, event, 0);
    
    if ([[event uppercaseString] isEqualToString:@"MOUSE_MOVED"]) {
        // only incur the cost for those who wish to pay the price
        [[SDMouseFollower sharedFollower] startListening];
    }
    else if ([[event uppercaseString] isEqualToString:@"MODIFIERS_CHANGED"]) {
        // only incur the cost for those who wish to pay the price
        [[SDModifierKeysListener sharedListener] startListening];
    }
    
    __weak SDTopLevelRef* _self = self;
    
    SDEventListener* listener = [[SDEventListener alloc] init];
    listener.eventName = event;
    listener.fn = ^(id thing) {
        id ref;
        
        if (thing == nil) {
            ref = [NSNull null];
        }
        else if ([thing isKindOfClass:[SDWindow self]]) {
            ref = [_self.client store: [SDWindowRef withResource: thing]];
        }
        else if ([thing isKindOfClass:[SDApp self]]) {
            ref = [_self.client store: [SDAppRef withResource: thing]];
        }
        else if ([thing isKindOfClass:[NSScreen self]]) {
            ref = [_self.client store: [SDScreenRef withResource: thing]];
        }
        else {
            ref = thing;
        }
        
        [_self.client sendResponse:ref forID:msgID];
    };
    
    [listener startListening];
    [self.listeners addObject:listener];
    
    return @-1;
}

- (id) unlisten:(NSArray*)args msgID:(id)msgID {
    SDTypeCheckArg(NSString, event, 0);
    
    for (SDEventListener* listener in self.listeners) {
        if ([listener.eventName isEqualToString:event]) {
            [listener stopListening];
            
            dispatch_async(dispatch_get_current_queue(), ^{
                [self.listeners removeObject: listener];
            });
        }
    }
    
    return [NSNull null];
}

- (id) relaunch_config:(NSArray*)args msgID:(id)msgID {
    [[SDConfigLauncher sharedConfigLauncher] launchConfigMaybe];
    return [NSNull null];
}

- (id) update_settings:(NSArray*)args msgID:(id)msgID {
    SDTypeCheckArg(NSDictionary, settings, 0);
    
    NSNumber* shouldAnimate = [settings objectForKey:@"alert_should_animate"];
    if ([shouldAnimate isKindOfClass: [NSNumber self]])
        [SDAlerts sharedAlerts].alertAnimates = [shouldAnimate boolValue];
    
    NSNumber* defaultDuration = [settings objectForKey:@"alert_default_delay"];
    if ([defaultDuration isKindOfClass: [NSNumber self]])
        [SDAlerts sharedAlerts].alertDisappearDelay = [defaultDuration doubleValue];
    
    return [NSNull null];
}

- (id) clipboard_contents:(NSArray*)args msgID:(id)msgID {
    return [[NSPasteboard generalPasteboard] stringForType:NSPasteboardTypeString];
}

- (id) focused_window:(NSArray*)args msgID:(id)msgID {
    return [self.client store: [SDWindowRef withResource: [SDWindow focusedWindow]]];
}

- (id) visible_windows:(NSArray*)args msgID:(id)msgID {
    return MAP([SDWindow visibleWindows], [self.client store: [SDWindowRef withResource: obj]]);
}

- (id) all_windows:(NSArray*)args msgID:(id)msgID {
    return MAP([SDWindow allWindows], [self.client store: [SDWindowRef withResource: obj]]);
}

- (id) main_screen:(NSArray*)args msgID:(id)msgID {
    return [self.client store: [SDScreenRef withResource: [NSScreen mainScreen]]];
}

- (id) all_screens:(NSArray*)args msgID:(id)msgID {
    return MAP([NSScreen screens], [self.client store: [SDScreenRef withResource: obj]]);
}

- (id) running_apps:(NSArray*)args msgID:(id)msgID {
    return MAP([SDApp runningApps], [self.client store: [SDAppRef withResource: obj]]);
}

- (id) log:(NSArray*)args msgID:(id)msgID {
    SDTypeCheckArg(NSString, str, 0);
    
    [[SDLogWindowController sharedLogWindowController] log:str
                                                      type:SDLogMessageTypeUser];
    return [NSNull null];
}

- (id) alert:(NSArray*)args msgID:(id)msgID {
    SDTypeCheckArg(NSString, msg, 0);
    NSNumber* duration = [args objectAtIndex:1];
    
    if ([duration isEqual: [NSNull null]]) {
        [[SDAlerts sharedAlerts] show:msg];
    }
    else {
        [[SDAlerts sharedAlerts] show:msg
                             duration:[duration doubleValue]];
    }
    
    return [NSNull null];
}

- (id) show_box:(NSArray*)args msgID:(id)msgID {
    SDTypeCheckArg(NSString, text, 0);
    [[SDBoxWindowController sharedBox] showWithText:text];
    return [NSNull null];
}

- (id) hide_box:(NSArray*)args msgID:(id)msgID {
    [[SDBoxWindowController sharedBox] hide];
    return [NSNull null];
}

- (id) choose_from:(NSArray*)args msgID:(id)msgID {
    SDTypeCheckArrayArg(list, NSString, 0);
    SDTypeCheckArg(NSString, title, 1);
    SDTypeCheckArg(NSNumber, lines, 2);
    SDTypeCheckArg(NSNumber, chars, 3);
    
    [NSApp activateIgnoringOtherApps:YES];
    [SDFuzzyMatcher showChoices:list
                      charsWide:[chars intValue]
                      linesTall:[lines intValue]
                    windowTitle:title
                  choseCallback:^(long chosenIndex) {
                      [NSApp hide:self];
                      [self.client sendResponse:@(chosenIndex) forID:msgID];
                  }
               canceledCallback:^{
                   [NSApp hide:self];
                   [self.client sendResponse:[NSNull null] forID:msgID];
               }];
    return @1;
}

@end
