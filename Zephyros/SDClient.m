//
//  SDClientInterface.m
//  Zephyros
//
//  Created by Steven on 8/11/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDClient.h"

#import "SDLogWindowController.h"

#import "SDTopLevelClientProxy.h"
#import "SDAppClientProxy.h"
#import "SDWindowClientProxy.h"
#import "SDScreenClientProxy.h"

#import "SDClient.h"

@interface SDClient ()

@property int64_t maxRespObjID;
@property NSMutableDictionary* returnedObjects;

@property SDTopLevelClientProxy* topLevel;

@end


@implementation SDClient

- (id) init {
    if (self = [super init]) {
        self.returnedObjects = [NSMutableDictionary dictionary];
        
        self.topLevel = [[SDTopLevelClientProxy alloc] init];
        self.topLevel.client = self;
        
        [self.returnedObjects setObject:self.topLevel forKey:[NSNull null]];
        [self.returnedObjects setObject:self.topLevel forKey:@0]; // backwards compatibility :'(
    }
    return self;
}

- (void) destroy {
    [self.topLevel destroy];
}

- (void) handleRequest:(NSArray*)msg {
    if ([msg count] < 3) {
        SDLogError(@"API error: invalid message: %@", msg);
        return;
    }
    
    id msgID = [msg objectAtIndex:0];
    
    if ([msgID isEqual:[NSNull null]]) {
        SDLogError(@"API error: invalid message id: %@", msgID);
        [self sendResponse:nil forID:msgID];
        return;
    }
    
    id recvID = [msg objectAtIndex:1];
    
    NSString* meth = [msg objectAtIndex:2];
    
    if (![meth isKindOfClass:[NSString self]] || [[meth stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        SDLogError(@"API error: invalid method name: %@", meth);
        [self sendResponse:nil forID:msgID];
        return;
    }
    
    NSArray* args = [msg subarrayWithRange:NSMakeRange(3, [msg count] - 3)];
    SDClientProxy* recv = [self.returnedObjects objectForKey:recvID];
    [recv delayDeath];
    
    if (recv == nil) {
        SDLogError(@"API Error: Could not find receiver with ID %@", recvID);
        [self sendResponse:nil forID:msgID];
        return;
    }
    
    SEL sel = NSSelectorFromString([[meth stringByReplacingOccurrencesOfString:@"?" withString:@"_q"] stringByAppendingString:@":msgID:"]);
    
    if (![recv respondsToSelector:sel]) {
        SDLogError(@"API Error: Could not find method %@.%@", [recv className], meth);
        [self sendResponse:nil forID:msgID];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        id result = nil;
        @try {
            #pragma clang diagnostic push // in' as you're shovin', and I'm slippin' back into... the gap again
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks" // *plonk*
            result = [recv performSelector:sel withObject:args withObject:msgID];
            #pragma clang diagnostic pop // rocks aren't all they're cracked up to be
        }
        @catch (NSException *exception) {
            SDLogError([exception description]);
        }
        @finally {
            [self sendResponse:result forID:msgID];
        }
    });
}

- (NSNumber*) storeObj:(id)obj withWrapper:(Class)wrapper {
    self.maxRespObjID++;
    NSNumber* newMaxID = @(self.maxRespObjID);
    
    SDClientProxy* wrappedObj = [[wrapper alloc] init];
    wrappedObj.client = self;
    wrappedObj.receiver = obj;
    
    [self.returnedObjects setObject:wrappedObj
                             forKey:newMaxID];
    
    wrappedObj.dieGroup = dispatch_group_create();
    [wrappedObj delayDeath];
    
    dispatch_group_notify(wrappedObj.dieGroup, dispatch_get_main_queue(), ^{
        [self.returnedObjects removeObjectForKey:newMaxID];
    });
    
    return newMaxID;
}

- (id) convertObj:(id)obj {
    if (obj == nil) {
        return [NSNull null];
    }
    else if ([obj isKindOfClass:[NSArray self]]) {
        NSMutableArray* newArray = [NSMutableArray array];
        
        for (id child in obj) {
            [newArray addObject:[self convertObj:child]];
        }
        
        return newArray;
    }
    else if ([obj isKindOfClass:[SDWindowProxy self]]) {
        return [self storeObj:obj withWrapper:[SDWindowClientProxy self]];
    }
    else if ([obj isKindOfClass:[SDScreenProxy self]]) {
        return [self storeObj:obj withWrapper:[SDScreenClientProxy self]];
    }
    else if ([obj isKindOfClass:[SDAppProxy self]]) {
        return [self storeObj:obj withWrapper:[SDAppClientProxy self]];
    }
    
    return obj;
}

- (void) sendResponse:(id)result forID:(NSNumber*)msgID {
    [self.delegate sendResponse:@[msgID, [self convertObj:result]]];
}

@end
