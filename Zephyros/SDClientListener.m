//
//  SDClientListener.m
//  Zephyros
//
//  Created by Steven Degutis on 7/31/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDClientListener.h"

#import "GCDAsyncSocket.h"

#import "SDClientBackend.h"

#import "SDLogWindowController.h"
#import "SDPreferencesWindowController.h"

#import "SDConfigLauncher.h"

@interface SDClientListener ()

@property GCDAsyncSocket* sock;
@property NSMutableArray* clients;

@end


@implementation SDClientListener

+ (SDClientListener*) sharedListener {
    static SDClientListener* sharedListener;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedListener = [[SDClientListener alloc] init];
    });
    return sharedListener;
}

- (id) init {
    if (self = [super init]) {
        self.clients = [NSMutableArray array];
    }
    return self;
}

- (void) startListening {
    [self.clients makeObjectsPerformSelector:@selector(disconnect)];
    
//    NSLog(@"re-listening");
    
    self.sock.delegate = nil;
    [self.sock disconnect];
    self.sock = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError* __autoreleasing error;
    BOOL worked;
    
    NSInteger socketType = [[NSUserDefaults standardUserDefaults] integerForKey:SDScriptSocketTypeDefaultsKey];
    if (socketType == 0) {
        worked = [self.sock acceptOnUrl:[NSURL fileURLWithPath:@"/tmp/zephyros.sock"]
                                  error:&error];
    }
    else {
        NSInteger tcpPort = [[NSUserDefaults standardUserDefaults] integerForKey:SDTCPSocketPortDefaultsKey];
        worked = [self.sock acceptOnInterface:@"localhost"
                                         port:tcpPort
                                        error:&error];
    }
    
    if (!worked) {
        SDLogError(@"Zephyros failed to start listening for scripts. Here's why: %@", error);
        SDLogError(@"Trying again in 60 seconds.");
        
        double delayInSeconds = 60.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self startListening];
        });
    }
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    SDClientBackend* client = [[SDClientBackend alloc] init];
    client.disconnectedHandler = ^(SDClientBackend* me){
        [self.clients removeObject:me];
    };
    newSocket.delegate = client;
    client.sock = newSocket;
    [self.clients addObject:client];
    
    [client waitForNewMessage];
}

@end
