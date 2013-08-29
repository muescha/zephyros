//
//  AppDelegate.m
//  Zephyros
//
//  Created by Steven on 4/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "AppDelegate.h"

#import "SDOpenAtLogin.h"
#import "SDConfigLauncher.h"
#import "SDAppStalker.h"

#import "SDLogWindowController.h"
#import "SDPreferencesWindowController.h"

#import "SDConfigLauncher.h"

#import "SDAlertWindowController.h"
#import "SDClientListener.h"
#import "SDMouseFollower.h"


@interface AppDelegate ()

@property NSStatusItem* statusItem;

@end

@implementation AppDelegate

- (void) prepareStatusItem {
    [[NSNotificationCenter defaultCenter] addObserverForName:SDScriptLaunchedNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      static BOOL firstTime = YES;
                                                      if (firstTime) {
                                                          firstTime = NO;
                                                      }
                                                      else {
                                                          [[SDAlerts sharedAlerts] show:@"Launched Zephyros Script"];
                                                      }
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SDScriptDiedNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [[SDAlerts sharedAlerts] show:@"Zephyros Script Ended"];
                                                  }];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [[NSImage imageNamed:@"statusitem"] setTemplate:YES];
    self.statusItem.image = [NSImage imageNamed:@"statusitem"];
    self.statusItem.menu = self.statusItemMenu;
    self.statusItem.highlightMode = YES;
}

- (void) applicationWillTerminate:(NSNotification *)notification {
    [[SDConfigLauncher sharedConfigLauncher] unlaunch];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString* runScript = [[NSUserDefaults standardUserDefaults] stringForKey:SDLaunchCommandDefaultsKey];
    BOOL usesLeinExec = (runScript != nil) && [runScript rangeOfString:@"lein exec"].location != NSNotFound;
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
     @"launchCommand": @"ruby ~/zephyros.rb   # or whatever",
                                 SDTCPSocketPortDefaultsKey: @1235,
                              SDScriptSocketTypeDefaultsKey: @(usesLeinExec ? 1 : 0),
     }];
    
    [self prepareStatusItem];
    
    [[SDClientListener sharedListener] startListening];
    [[SDConfigLauncher sharedConfigLauncher] launchConfigMaybe];
    [[SDAppStalker sharedAppStalker] beginStalking];
    
    [[SDAlerts sharedAlerts] show:@"Zephyros power, activate!"
                         duration:1.5];
}

- (IBAction) showPreferencesWindow:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [[SDPreferencesWindowController sharedConfigChooserWindowController] show];
}

- (IBAction) relaunchConfig:(id)sender {
    [[SDConfigLauncher sharedConfigLauncher] launchConfigMaybe];
}

- (void) menuNeedsUpdate:(NSMenu *)menu {
    [[menu itemWithTitle:@"Open at Login"] setState:([SDOpenAtLogin opensAtLogin] ? NSOnState : NSOffState)];
}

- (IBAction) showLogWindow:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [[SDLogWindowController sharedLogWindowController] showWindow:self];
}

- (IBAction) showAboutPanel:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:sender];
}

- (IBAction) toggleOpensAtLogin:(id)sender {
	NSInteger changingToState = ![sender state];
	[SDOpenAtLogin setOpensAtLogin: changingToState];
}

@end
