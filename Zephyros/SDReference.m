//
//  SDClientProxy.m
//  Zephyros
//
//  Created by Steven Degutis on 8/12/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDReference.h"

#import "SDLogWindowController.h"

@implementation SDReference

- (void) dealloc {
//    NSLog(@"ref was deallocated: %@", self.resource);
    [[self.client undoManager] removeAllActionsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL) isEqual:(SDReference*)other {
    return ([self isKindOfClass: [other class]] &&
            [self.resource isEqual: other.resource]);
}

- (NSUInteger) hash {
    return [self.resource hash];
}

- (id) withUndo {
    return [[self.client undoManager] prepareWithInvocationTarget:self];
}

- (void) whenDead:(void(^)())block {
}

- (id) check:(NSArray*)args atIndex:(int)idx forType:(Class)klass inFn:(SEL)fn {
    id obj = [args objectAtIndex:idx];
    
    if ([obj isKindOfClass:klass])
        return obj;
    
    NSString* method = [NSStringFromSelector(fn) stringByReplacingOccurrencesOfString:@":msgID:" withString:@""];
    NSString* objectDesc = [self className];
    objectDesc = [objectDesc substringWithRange:NSMakeRange(2, [objectDesc length] - 13)];
    
    SDLogError(@"API Error: in %@.%@, argument %d was expected to be type %@ but was %@",
               objectDesc,
               method,
               idx,
               klass,
               obj);
    
    return nil;
}

- (NSArray*) check:(NSArray*)args atIndex:(int)idx forElementType:(Class)klass inFn:(SEL)fn {
    id obj = [self check:args atIndex:idx forType:[NSArray self] inFn:fn];
    
    if (obj) {
        int i = 0;
        for (id elem in obj) {
            if (![elem isKindOfClass:klass]) {
                NSString* method = [NSStringFromSelector(fn) stringByReplacingOccurrencesOfString:@":msgID:" withString:@""];
                NSString* objectDesc = [self className];
                objectDesc = [objectDesc substringWithRange:NSMakeRange(2, [objectDesc length] - 13)];
                
                SDLogError(@"API Error: in %@.%@, element %d (of argument %d) was expected to be type %@ but was %@",
                           objectDesc,
                           method,
                           idx,
                           i,
                           klass,
                           elem);
                
                return nil;
            }
            i++;
        }
    }
    
    return obj;
}

+ (id) withResource:(id)resource {
    SDReference* ref = [[self alloc] init];
    ref.resource = resource;
    return ref;
}

@end
