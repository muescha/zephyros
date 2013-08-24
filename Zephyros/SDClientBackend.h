//
//  SDClient.h
//  Zephyros
//
//  Created by Steven Degutis on 7/31/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCDAsyncSocket.h"

#import "SDClient.h"

@interface SDClientBackend : NSObject <SDClientDelegate>

@property GCDAsyncSocket* sock;

- (void) waitForNewMessage;

@property (copy) void(^disconnectedHandler)(SDClientBackend* me);

- (void) destroy;

@end
