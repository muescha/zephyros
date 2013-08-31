//
//  SDRefCache.h
//  Zephyros
//
//  Created by Steven Degutis on 8/30/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SDReference;

@interface SDRefCache : NSObject

- (SDReference*) refForKey:(id)key;
- (id) storeRef:(SDReference*)ref;
- (void) removeRefForKey:(id)key;

// only used for top-level obj
- (void) store:(SDReference*)obj withKey:(id)key;

@end
