//
//  SDConfigLoader.h
//  Zephyros
//
//  Created by Steven on 4/15/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SDScriptLaunchedNotification @"SDScriptLaunchedNotification"
#define SDScriptDiedNotification @"SDScriptDiedNotification"

@interface SDConfigLauncher : NSObject

+ (SDConfigLauncher*) sharedConfigLauncher;

- (void) launchConfigMaybe;
- (void) watchPathsMaybe;

- (void) startOrStopScript;

- (void) unlaunch;
- (void) watchPaths;
- (void) unwatchPaths;

@property (readonly) BOOL isRunning;

- (void) somePathChanged:(id)alwaysNil;

@end
