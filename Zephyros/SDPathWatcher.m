//
//  SDConfigWatcher.m
//  Zephyros
//
//  Created by Steven on 7/28/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDPathWatcher.h"

#import "SDConfigLauncher.h"

@interface SDPathWatcher ()

@property FSEventStreamRef stream;

@end



void fsEventsCallback(ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[])
{
    SDConfigLauncher* launcher = [SDConfigLauncher sharedConfigLauncher];
    [SDConfigLauncher cancelPreviousPerformRequestsWithTarget:launcher selector:@selector(somePathChanged:) object:nil];
    [launcher performSelector:@selector(somePathChanged:) withObject:nil afterDelay:0.2];
}



@implementation SDPathWatcher

- (void) dealloc {
    if (self.stream) {
        FSEventStreamStop(self.stream);
        FSEventStreamInvalidate(self.stream);
        FSEventStreamRelease(self.stream);
    }
}

+ (SDPathWatcher*) watcherFor:(NSArray*)pathsToWatch {
    SDPathWatcher* watcher = [[SDPathWatcher alloc] init];
    
    if ([pathsToWatch count] == 0)
        return nil;
    
    pathsToWatch = [pathsToWatch valueForKeyPath:@"stringByStandardizingPath"];
    
    FSEventStreamContext context;
    context.info = NULL;
    context.version = 0;
    context.retain = NULL;
    context.release = NULL;
    context.copyDescription = NULL;
    watcher.stream = FSEventStreamCreate(NULL,
                                         fsEventsCallback,
                                         &context,
                                         (__bridge CFArrayRef)pathsToWatch,
                                         kFSEventStreamEventIdSinceNow,
                                         0.4,
                                         kFSEventStreamCreateFlagWatchRoot | kFSEventStreamCreateFlagNoDefer | kFSEventStreamCreateFlagFileEvents);
    FSEventStreamScheduleWithRunLoop(watcher.stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamStart(watcher.stream);
    
    return watcher;
}

@end
