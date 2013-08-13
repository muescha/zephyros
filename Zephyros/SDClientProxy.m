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

- (void) argumentError:(SEL)sel index:(int)idx wantedClass:(Class)klass got:(id)realArg {
    NSString* method = [NSStringFromSelector(sel) stringByReplacingOccurrencesOfString:@":msgID:" withString:@""];
    NSString* objectDesc = [self className];
    objectDesc = [objectDesc substringWithRange:NSMakeRange(2, [objectDesc length] - 13)];
    [self.client showAPIError:[NSString stringWithFormat:
                               @"API Error: in %@.%@, argument %d was expected to be type %@ but was %@",
                               objectDesc,
                               method,
                               idx,
                               [klass self],
                               realArg]];
}

- (void) arrayError:(SEL)sel index:(int)idx wantedClass:(Class)klass got:(id)realArg {
    NSString* method = [NSStringFromSelector(sel) stringByReplacingOccurrencesOfString:@":msgID:" withString:@""];
    NSString* objectDesc = [self className];
    objectDesc = [objectDesc substringWithRange:NSMakeRange(2, [objectDesc length] - 13)];
    [self.client showAPIError:[NSString stringWithFormat:@"API Error: in %@.%@, element %d (of some array) was expected to be type %@ but was %@",
                               objectDesc,
                               method,
                               idx,
                               [klass self],
                               realArg]];
}

@end
