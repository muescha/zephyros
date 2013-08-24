//
//  SDModifierKeysListener.h
//  Zephyros
//
//  Created by Steven on 8/24/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDModifierKeysListener : NSObject

+ (SDModifierKeysListener*) sharedListener;

- (void) startListening;

@end
