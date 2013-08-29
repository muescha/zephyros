//
//  SDZephClient.m
//  zephjs
//
//  Created by Steven on 8/5/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDZephClient.h"




#import "GCDAsyncSocket.h"

#define FOREVER (-1)


// copied verbatim from http://nullpointer.ph/questions/339/how-do-you-implement-a-thread-safe-queue-for-objective-c
@interface SDQueue : NSObject
@property (retain) NSCondition* queueLock;
@property (retain) NSMutableArray* queueContents;
@end

@implementation SDQueue

- (id) init {
    if (self = [super init]) {
        self.queueLock = [[NSCondition alloc] init];
        self.queueContents = [NSMutableArray array];
    }
    return self;
}

- (id) get {
    id toRet = nil;
    [self.queueLock lock];
    @try
    {
    	while ([self.queueContents count] == 0)
    	{
    		[self.queueLock wait];
    	}
        
    	toRet = [self.queueContents lastObject];
    	[self.queueContents removeLastObject];
    }
    @finally
    {
    	[self.queueLock unlock];
    	return toRet;
    }
}

- (void) put:(id) putObject
{
    [self.queueLock lock];
    @try
    {
    	[self.queueContents insertObject:putObject atIndex:0];
    	[self.queueLock broadcast];
    }
    @finally
    {
    	[self.queueLock unlock];
    }
}

@end




@interface SDZephClient ()

@property (retain) GCDAsyncSocket* sock;
@property uint64_t maxMsgId;
@property (retain) NSMutableDictionary* queues;

@end


@implementation SDZephClient


- (void) sendAsyncMessage:(id)msg responses:(int)responses callback:(void(^)(id obj))callback {
    uint64_t msgid = ++self.maxMsgId;
    
    NSNumber* msgIdNum = @(msgid);
    
    SDQueue* queue = [[SDQueue alloc] init];
    [self.queues setObject:queue forKey:msgIdNum];
    
    NSMutableArray* newMsg = [msg mutableCopy];
    [newMsg insertObject:msgIdNum atIndex:0];
    
//    NSLog(@"msg %@ = %@", msgIdNum, newMsg);
    
    NSData* msgData = [NSJSONSerialization dataWithJSONObject:newMsg options:0 error:NULL];
    
    [self.sock writeData:msgData withTimeout:3 tag:0];
    [self.sock writeData:[GCDAsyncSocket LFData] withTimeout:3 tag:0];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (responses == -1) {
//            NSLog(@"ignoring first = %@", [queue get]);
            [queue get]; // ignore first
            while (true) {
                id obj = [queue get];
//                NSLog(@"infinite got = %@", obj);
                callback(obj);
            }
        }
        else {
            for (int i = 0; i < responses; i++) {
                id obj = [queue get];
//                NSLog(@"once got = %@ for msg id = %@", obj, msgIdNum);
                callback(obj);
//                NSLog(@"done calling back got = %@ for msg id = %@", obj, msgIdNum);
            }
        }
        
        [self.queues removeObjectForKey:msgIdNum];
    });
}

- (id) sendSyncMessage:(id)msg {
    __block id returnVal = nil;
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendAsyncMessage:msg responses:1 callback:^(id obj) {
            returnVal = obj;
            
            dispatch_group_leave(group);
        }];
    });
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    return returnVal;
}

- (BOOL) connect {
    self.queues = [NSMutableDictionary dictionary];
    
    self.sock = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    BOOL connected = [self.sock connectToUrl:[NSURL fileURLWithPath:@"/tmp/zephyros.sock"]
                                 withTimeout:FOREVER
                                       error:NULL];
//    BOOL connected = [self.sock connectToHost:@"localhost" onPort:1235 error:NULL];
    
    [self waitForNewMessage];
    return connected;
}

- (void) waitForNewMessage {
    [self.sock readDataToData:[GCDAsyncSocket LFData] withTimeout:FOREVER tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    if (self.errorCallback)
        self.errorCallback(err);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSArray* msg = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:NULL];
    id msgId = [msg objectAtIndex:0];
    id value = [msg objectAtIndex:1];
    
//        NSLog(@"got msg #%@: %@", msgId, value);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SDQueue* queue = [self.queues objectForKey:msgId];
        [queue put:value];
    });
    
    [self waitForNewMessage];
}

@end
