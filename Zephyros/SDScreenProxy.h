//
//  NSScreenProxy.h
//  Zephyros
//
//  Created by Steven on 4/14/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDScreenProxy : NSObject

@property (strong) NSScreen* actualScreenObject;

+ (SDScreenProxy*) mainScreen;
+ (NSArray*) allScreens;

- (CGRect) frameIncludingDockAndMenu;
- (CGRect) frameWithoutDockOrMenu;

- (SDScreenProxy*) nextScreen;
- (SDScreenProxy*) previousScreen;

- (BOOL) rotateTo:(int)degrees;

@end
