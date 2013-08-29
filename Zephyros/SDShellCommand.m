//
//  SDShellCommand.m
//  Zephyros
//
//  Created by Steven Degutis on 8/3/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDShellCommand.h"

@interface SDShellCommand ()

@property NSTask* task;
@property NSTask* taskLifeWatcher;

@property NSPipe* stdoutPipe;
@property NSPipe* stderrPipe;

@end

@implementation SDShellCommand

- (void) launch {
    self.stdoutPipe = [NSPipe pipe];
    self.stderrPipe = [NSPipe pipe];
    
    self.task = [[NSTask alloc] init];
    
    [self.task setLaunchPath:@"/bin/bash"];
    [self.task setArguments:@[@"-l", @"-c", self.cmd]];
    
    [self.task setStandardOutput:self.stdoutPipe];
    [self.task setStandardError:self.stderrPipe];
    
    self.taskLifeWatcher =
    [[NSNotificationCenter defaultCenter] addObserverForName:NSTaskDidTerminateNotification
                                                      object:self.task
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self taskDied];
                                                  }];
    
    if (self.gotStdout)
        [self.stdoutPipe fileHandleForReading].readabilityHandler = self.gotStdout;
    
    if (self.gotStderr)
        [self.stderrPipe fileHandleForReading].readabilityHandler = self.gotStderr;
    
    [self.task launch];
}

- (void) kill {
//    NSLog(@"killed");
    [self closePipes];
    
    pid_t p = [self.task processIdentifier];
    [self.task terminate];
    kill(p, SIGKILL);
    self.task = nil;
}

- (BOOL) isRunning {
    return [self.task isRunning];
}

- (void) closePipes {
    [self.stdoutPipe.fileHandleForReading closeFile];
    [self.stderrPipe.fileHandleForReading closeFile];
    
    self.stdoutPipe = nil;
    self.stderrPipe = nil;
}

- (void) taskDied {
//    NSLog(@"died");
    [self closePipes];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.taskLifeWatcher];
    
    if (self.died)
        self.died();
}

@end
