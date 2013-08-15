//
//  SDClientProxy.m
//  Zephyros
//
//  Created by Steven Degutis on 8/12/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDClientProxy.h"

#import "SDLogWindowController.h"

@implementation SDClientProxy

- (void) delayDeath {
    dispatch_group_enter(self.dieGroup);
    double delayInSeconds = 60.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        dispatch_group_leave(self.dieGroup);
    });
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

@end
