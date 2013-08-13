//
//  SDMouseFollower.h
//  Zephyros
//
//  Created by Steven on 8/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDMouseFollower : NSObject

+ (SDMouseFollower*) sharedFollower;

- (void) startListening;

@end
