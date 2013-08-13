//
//  SDBoxWindowController.m
//  Zephyros
//
//  Created by Steven on 8/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDBoxWindowController.h"

@interface SDBoxWindowController ()

@property IBOutlet NSTextField* textField;

@end

@implementation SDBoxWindowController

+ (SDBoxWindowController*) sharedBox {
    static SDBoxWindowController* sharedBox;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBox = [[SDBoxWindowController alloc] init];
    });
    return sharedBox;
}

- (NSString*) windowNibName {
    return @"SDBoxWindow";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.styleMask = NSBorderlessWindowMask;
    self.window.backgroundColor = [NSColor clearColor];
    self.window.opaque = NO;
    self.window.level = NSFloatingWindowLevel;
    self.window.ignoresMouseEvents = YES;
    self.window.animationBehavior = NSWindowAnimationBehaviorNone;
}

- (void) showWithText:(NSString*)text {
    [self window]; // sigh; required cuz nib hasnt loaded yet
    
    [self useTitleAndResize:text];
    [self relegateWindowToCorner];
    [self showWindow:self];
}

- (void) hide {
    [self close];
}

- (void) relegateWindowToCorner {
    NSScreen* currentScreen = [NSScreen mainScreen];
    NSRect screenBounds = [currentScreen visibleFrame];
    
    screenBounds = NSInsetRect(screenBounds, 20, 20);
    
	NSRect windowFrame = [[self window] frame];
    
    windowFrame.origin.x = NSMinX(screenBounds);
    windowFrame.origin.y = NSMaxY(screenBounds) - NSHeight(windowFrame);
    
	[[self window] setFrame:windowFrame display:NO];
}

- (void) useTitleAndResize:(NSString*)title {
    self.textField.stringValue = title;
    [self.textField sizeToFit];
    
    NSRect textFrame = self.textField.frame;
    
	NSRect windowFrame = [[self window] frame];
	windowFrame.size.width = [self.textField frame].size.width + 20.0;
	windowFrame.size.height = [self.textField frame].size.height + 20.0;
	[[self window] setFrame:windowFrame display:NO];
    
    textFrame.origin = NSMakePoint(10, 10);
    [self.textField setFrame:textFrame];
}

@end
