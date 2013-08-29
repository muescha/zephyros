//
//  SDClientProxy.m
//  Zephyros
//
//  Created by Steven Degutis on 8/12/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDClientProxy.h"

#import "SDLogWindowController.h"

@interface SDClientProxy ()

@property int refRetainCount;

@end

@implementation SDClientProxy

- (void) reallyDie {
    self.whenFinallyDead();
}

- (id) withUndo {
    [self retainRef];
    [self releaseRef];
    return [[self.client undoManager] prepareWithInvocationTarget:self];
}

- (void) retainRef {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(reallyDie) object:nil];
    
    self.refRetainCount++;
}

- (void) releaseRef {
    self.refRetainCount--;
    
    if (self.refRetainCount == 0) {
        [self performSelector:@selector(reallyDie) withObject:nil afterDelay:5.0];
    }
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

- (id) retain:(NSArray*)args msgID:(id)msgID {
    [self retainRef];
    return nil;
}

- (id) release:(NSArray*)args msgID:(id)msgID {
    [self releaseRef];
    return nil;
}

@end
