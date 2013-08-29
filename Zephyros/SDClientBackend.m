//
//  SDClient.m
//  Zephyros
//
//  Created by Steven Degutis on 7/31/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDClientBackend.h"

#import "SDClient.h"
#import "SDLogWindowController.h"

#define FOREVER (-1)

@interface SDClientBackend ()

@property SDClient* client;

@end


@implementation SDClientBackend

- (id) init {
    if (self = [super init]) {
        self.client = [[SDClient alloc] init];
        self.client.delegate = self;
    }
    return self;
}

- (void) waitForNewMessage {
    [self.sock readDataToData:[GCDAsyncSocket LFData]
                  withTimeout:FOREVER
                          tag:0];
}

- (void) sendResponse:(id)msg {
//    NSLog(@"sending [%@]", msg);
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:msg options:0 error:NULL];
    
    NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [[SDLogWindowController sharedLogWindowController] log:dataStr type:SDLogMessageTypeResponse];
    
    [self.sock writeData:data withTimeout:3 tag:0];
    [self.sock writeData:[GCDAsyncSocket LFData] withTimeout:3 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSError* __autoreleasing error;
    id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSString* rawJson = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (obj == nil) {
        SDLogError(@"API Error: expected valid JSON message, got: %@", rawJson);
        [self waitForNewMessage];
    }
    else {
        [[SDLogWindowController sharedLogWindowController] log:rawJson type:SDLogMessageTypeRequest];
        
        [self.client handleRequest:obj];
        [self waitForNewMessage];
    }
}

- (void) disconnect {
    [self.sock disconnectAfterReadingAndWriting];
    [self destroy];
}

- (void) destroy {
    self.sock.delegate = nil;
    self.sock = nil;
    [self.client destroy];
    self.disconnectedHandler(self);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
//    NSLog(@"did disconnect");
    [self destroy];
}

@end
