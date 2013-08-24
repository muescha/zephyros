//
//  main.m
//  zephjs
//
//  Created by Steven Degutis on 8/4/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDZephJS.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc != 2) {
            printf("usage: zephjs script.js\n"
                   "       zephjs script.coffee\n");
            return 1;
        }
        
        NSString* file = [NSString stringWithUTF8String:argv[1]];
        BOOL coffee = [file hasSuffix:@".coffee"];
        
        NSData* contentsData = [[NSFileManager defaultManager] contentsAtPath:file];
        if (contentsData == nil) {
            printf("Couldn't read file: %s\n", [file UTF8String]);
            printf("Are you sure it exists? Maybe you made a typo?\n");
            return 0;
        }
        
        [[SDZephJS sharedZeph] setup];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[SDZephJS sharedZeph] evalFile:contentsData asCoffee:coffee];
        });
        dispatch_main();
    }
    return 0;
}
