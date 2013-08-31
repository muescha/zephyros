//
//  SDClientProxy.h
//  Zephyros
//
//  Created by Steven Degutis on 8/12/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDClient.h"

@interface SDReference : NSObject

@property (weak) SDClient* client;
@property id resource;

- (void) whenDead:(void(^)())block;

+ (id) withResource:(id)resource;

- (id) withUndo;

- (id) check:(NSArray*)args atIndex:(int)idx forType:(Class)klass inFn:(SEL)fn;
- (NSArray*) check:(NSArray*)args atIndex:(int)idx forElementType:(Class)klass inFn:(SEL)fn;

@end


#define SDTypeCheckArg(klass, name, idx) \
klass* name; \
do { \
    if (!(name = [self check:args atIndex:idx forType:[klass self] inFn:_cmd])) return nil; \
} while(0)


#define SDTypeCheckArrayArg(name, elemklass, idx) \
NSArray* name; \
do { \
if (!(name = [self check:args atIndex:idx forElementType:[elemklass self] inFn:_cmd])) return nil; \
} while(0)
