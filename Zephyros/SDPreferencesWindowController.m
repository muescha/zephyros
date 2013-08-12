//
//  SDConfigChooserWindowController.m
//  Zephyros
//
//  Created by Steven on 7/28/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDPreferencesWindowController.h"

#import "SDConfigLauncher.h"

#import "SDClientListener.h"

@interface SDPreferencesWindowController ()

@property BOOL scriptRunning;
@property (readonly) BOOL watchedPathsHasChanges;
@property NSString* tempRelaunchPaths;

@end



@interface SDRightMarginTextFieldCell : NSTextFieldCell
@end
@implementation SDRightMarginTextFieldCell

- (NSRect)drawingRectForBounds:(NSRect)theRect {
    theRect = [super drawingRectForBounds:theRect];
    theRect.size.width -= 18;
    return theRect;
}

@end


@interface SDStartOrStopScriptTitleTransformer : NSValueTransformer
@end
@implementation SDStartOrStopScriptTitleTransformer
+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    if ([value boolValue])
        return @"Kill";
    else
        return @"Run";
}
@end


@interface SDScriptRunningImageTransformer : NSValueTransformer
@end
@implementation SDScriptRunningImageTransformer
+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    if ([value boolValue])
        return [NSImage imageNamed:NSImageNameStatusAvailable];
    else
        return [NSImage imageNamed:NSImageNameStatusUnavailable];
}
@end



@implementation SDPreferencesWindowController

+ (SDPreferencesWindowController*) sharedConfigChooserWindowController {
    static SDPreferencesWindowController* sharedConfigChooserWindowController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConfigChooserWindowController = [[SDPreferencesWindowController alloc] init];
    });
    return sharedConfigChooserWindowController;
}

- (id) init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserverForName:SDScriptLaunchedNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          self.scriptRunning = YES;
                                                      }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:SDScriptDiedNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          self.scriptRunning = NO;
                                                      }];
        
        self.tempRelaunchPaths = [[NSUserDefaults standardUserDefaults] stringForKey:SDRelaunchPathsDefaultsKey];
    }
    return self;
}

- (NSString*) windowNibName {
    return @"SDPreferencesWindow";
}

- (void) show {
    self.scriptRunning = [SDConfigLauncher sharedConfigLauncher].isRunning;
    
    [[self window] center];
    [self showWindow:self];
}




// run script

- (IBAction) toggleKeepMyScriptAlive:(id)sender {
    if ([sender state] == NSOffState) {
        [[SDConfigLauncher sharedConfigLauncher] unlaunch];
    }
}

- (IBAction) startOrStopScript:(id)sender {
    [[SDConfigLauncher sharedConfigLauncher] startOrStopScript];
}





// changing paths

- (IBAction) changePaths:(id)sender {
    [self willChangeValueForKey:@"watchedPathsHasChanges"];
    [self setValue:self.tempRelaunchPaths forKeyPath:@"defaults.values.relaunchPaths"];
    [self didChangeValueForKey:@"watchedPathsHasChanges"];
    
    [[SDConfigLauncher sharedConfigLauncher] watchPaths];
}

- (BOOL) watchedPathsHasChanges {
    NSString* str1 = [[[self defaults] values] valueForKeyPath:@"relaunchPaths"];
    NSString* str2 = self.tempRelaunchPaths;
    return ![str1 isEqualToString: str2];
}

- (NSUserDefaultsController*) defaults {
    // only used for my hacky bindings trick
    return [NSUserDefaultsController sharedUserDefaultsController];
}

+ (NSSet*) keyPathsForValuesAffectingWatchedPathsHasChanges {
    return [NSSet setWithArray:@[@"tempRelaunchPaths", @"defaults.values.relaunchPaths"]];
}

- (IBAction) toggleWatchPaths:(id)sender {
    if ([sender state] == NSOnState) {
        [[SDConfigLauncher sharedConfigLauncher] watchPaths];
    }
    if ([sender state] == NSOffState) {
        [[SDConfigLauncher sharedConfigLauncher] unwatchPaths];
    }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command {
    if (command == @selector(insertNewline:)) {
        [textView insertNewlineIgnoringFieldEditor:self];
        return YES;
    }
    return NO;
}



// migrating configs

- (IBAction) migrate3xConfigs:(id)sender {
    [self willChangeValueForKey:@"watchedPathsHasChanges"];
    [self setValue:[self newBashCommandString] forKeyPath:@"defaults.values.launchCommand"];
    [self didChangeValueForKey:@"watchedPathsHasChanges"];
}

- (NSString*) newBashCommandString {
    NSString* zephjs = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/MacOS/zephjs"];
    NSString* config = @"~/.zephyros.js";
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[@"~/.zephyros.coffee" stringByStandardizingPath]])
        config = @"~/.zephyros.coffee";
    
    return [NSString stringWithFormat:@"%@ %@", zephjs, config];
}



// unix and tcp sockets

- (IBAction) switchSocketType:(id)sender {
    [[SDClientListener sharedListener] startListening];
}

- (IBAction) switchSocketPort:(id)sender {
    [[SDClientListener sharedListener] startListening];
}

@end
