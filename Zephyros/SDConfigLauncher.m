//
//  SDConfigLoader.m
//  Zephyros
//
//  Created by Steven on 4/15/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDConfigLauncher.h"

#import "SDPreferencesWindowController.h"
#import "SDPathWatcher.h"

#import "SDLogWindowController.h"
#import "SDAlertWindowController.h"
#import "SDBoxWindowController.h"

#import "SDShellCommand.h"

@interface SDConfigLauncher ()

@property SDPathWatcher* configWatcher;
@property SDShellCommand* launchedTask;

@property BOOL isRunning;

@end


@implementation SDConfigLauncher

+ (SDConfigLauncher*) sharedConfigLauncher {
    static SDConfigLauncher* sharedConfigLauncher;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConfigLauncher = [[SDConfigLauncher alloc] init];
        sharedConfigLauncher.configWatcher = [[SDPathWatcher alloc] init];
    });
    return sharedConfigLauncher;
}

- (void) launchConfigMaybe {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SDBoxWindowController sharedBox] hide];
        
        NSString* cmd = [[NSUserDefaults standardUserDefaults] stringForKey:SDLaunchCommandDefaultsKey];
        BOOL shouldLaunchConfig = [[NSUserDefaults standardUserDefaults] boolForKey:SDRunMyScriptDefaultsKey] && [cmd length] > 0;
        
        if (shouldLaunchConfig) {
            [self unlaunch];
            
            double delayInSeconds = 0.15;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self launch];
            });
        }
        else {
            [self unlaunch];
            self.configWatcher = nil;
        }
        
        [self watchPathsMaybe];
    });
}

- (void) watchPathsMaybe {
    BOOL shouldLaunchConfig = [[NSUserDefaults standardUserDefaults] boolForKey:SDRunMyScriptDefaultsKey];
    BOOL shouldWatchPaths = [[NSUserDefaults standardUserDefaults] boolForKey:SDUseRelaunchPathsDefaultsKey];
    
    if (shouldLaunchConfig && shouldWatchPaths)
        [self watchPaths];
    else
        [self unwatchPaths];
}

- (void) watchPaths {
    NSString* pathsStr = [[NSUserDefaults standardUserDefaults] stringForKey:SDRelaunchPathsDefaultsKey];
    NSArray* paths = [pathsStr componentsSeparatedByString:@"\n"];
    self.configWatcher = [SDPathWatcher watcherFor:paths];
}

- (void) startOrStopScript {
    if (self.isRunning) {
        [self unlaunch];
    }
    else {
        [self launch];
    }
}

- (void) unwatchPaths {
    self.configWatcher = nil;
}




- (void) somePathChanged:(id)alwaysNil {
    [self launchConfigMaybe];
}




- (void) prelaunchMaybe {
    BOOL shouldPrelaunch = [[NSUserDefaults standardUserDefaults] boolForKey:SDRunCommandFirstDefaultsKey];
    
    if (!shouldPrelaunch)
        return;
    
    NSString* prelaunchCmd = [[NSUserDefaults standardUserDefaults] stringForKey:SDPrerunCommandDefaultsKey];
    
    NSTask* task = [NSTask launchedTaskWithLaunchPath:@"/bin/bash" arguments:@[@"-l", @"-c", prelaunchCmd]];
    [task waitUntilExit];
}

- (void) launch {
//    NSLog(@"launching");
    [self prelaunchMaybe];
    
    NSString* cmd = [[NSUserDefaults standardUserDefaults] stringForKey:SDLaunchCommandDefaultsKey];
    
    self.launchedTask = [[SDShellCommand alloc] init];
    self.launchedTask.cmd = cmd;
    self.launchedTask.gotStdout = ^(NSFileHandle* handle) {
        NSData* data = [handle availableData];
        NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[SDLogWindowController sharedLogWindowController] log:str
                                                              type:SDLogMessageTypeUser];
        });
    };
    self.launchedTask.gotStderr = ^(NSFileHandle* handle) {
        NSData* data = [handle availableData];
        NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[SDLogWindowController sharedLogWindowController] log:str
                                                              type:SDLogMessageTypeError];
        });
    };
    
    __weak SDConfigLauncher* punyself = self;
    self.launchedTask.died = ^{
        punyself.isRunning = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:SDScriptDiedNotification object:nil];
        punyself.launchedTask = nil;
    };
    
    [self.launchedTask launch];
    
    self.isRunning = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:SDScriptLaunchedNotification object:nil];
}

- (void) unlaunch {
//    NSLog(@"killing");
    [self.launchedTask kill];
    self.launchedTask = nil;
}

@end
