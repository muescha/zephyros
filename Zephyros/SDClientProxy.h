//
//  SDClientProxy.h
//  Zephyros
//
//  Created by Steven Degutis on 8/12/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDClient.h"

@interface SDClientProxy : NSObject

@property (weak) SDClient* client;
@property id receiver;

- (void) argumentError:(SEL)sel index:(int)idx wantedClass:(Class)klass got:(id)realArg;
- (void) arrayError:(SEL)sel index:(int)idx wantedClass:(Class)klass got:(id)realArg;

@end




#define SDTypeCheckArg(klass, name, idx) \
klass* name; \
do { \
    id arg = [args objectAtIndex:idx]; \
    if (![arg isKindOfClass:[klass self]]) { \
        [self argumentError:_cmd index:idx wantedClass:[klass self] got:arg]; \
        return nil; \
    } \
    name = arg; \
} while(0)



#define SDTypeCheckArray(ary, klass) \
do { \
    int idx = 0; \
    for (id obj in ary) { \
        if (![obj isKindOfClass:[klass self]]) { \
            [self arrayError:_cmd index:idx wantedClass:[klass self] got:obj]; \
            return nil; \
        } \
        idx++; \
    } \
} while(0)
