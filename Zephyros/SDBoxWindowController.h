//
//  SDBoxWindowController.h
//  Zephyros
//
//  Created by Steven on 8/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SDBoxWindowController : NSWindowController

+ (SDBoxWindowController*) sharedBox;

- (void) showWithText:(NSString*)text;
- (void) hide;

@end
