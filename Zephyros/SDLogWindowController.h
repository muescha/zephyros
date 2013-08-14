//
//  SDConfigProblemReporter.h
//  Zephyros
//
//  Created by Steven on 4/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum _SDLogMessageType {
    SDLogMessageTypeError,
    SDLogMessageTypeUser,
    SDLogMessageTypeRequest,
    SDLogMessageTypeResponse,
} SDLogMessageType;

@interface SDLogWindowController : NSWindowController <NSWindowDelegate>

+ (SDLogWindowController*) sharedLogWindowController;

- (void) show:(NSString*)message type:(SDLogMessageType)type;
- (void) log:(NSString*)message type:(SDLogMessageType)type;

@end
