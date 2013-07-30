//
//  SDConfigLoader.h
//  Zephyros
//
//  Created by Steven on 4/15/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDConfigLoader : NSObject

+ (SDConfigLoader*) sharedConfigLoader;

- (void) prepareScriptingBridge;
- (void) reloadConfig;
- (void) reloadConfigIfWatchEnabled;

- (NSString*) evalString:(NSString*)str;

@end
