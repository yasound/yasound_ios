//
//  BasicExampleAppDelegate.m
//  Google Analytics iPhone SDK.
//
//  Copyright 2009 Google Inc. All rights reserved.
//

#import "BasicExampleAppDelegate.h"

#import "GANTracker.h"

// Dispatch period in seconds
static const NSInteger kGANDispatchPeriodSec = 10;

@implementation BasicExampleAppDelegate

@synthesize window = window_;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
  // **************************************************************************
  // PLEASE REPLACE WITH YOUR ACCOUNT DETAILS.
  // **************************************************************************
  [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-00000000-1"
                                         dispatchPeriod:kGANDispatchPeriodSec
                                               delegate:nil];
  NSError *error;

  if (![[GANTracker sharedTracker] setCustomVariableAtIndex:1
                                                       name:@"iPhone1"
                                                      value:@"iv1"
                                                  withError:&error]) {
    NSLog(@"error in setCustomVariableAtIndex");
  }

  if (![[GANTracker sharedTracker] trackEvent:@"Application iPhone"
                                       action:@"Launch iPhone"
                                        label:@"Example iPhone"
                                        value:99
                                    withError:&error]) {
    NSLog(@"error in trackEvent");
  }

  if (![[GANTracker sharedTracker] trackPageview:@"/app_entry_point"
                                       withError:&error]) {
    NSLog(@"error in trackPageview");
  }
  [window_ makeKeyAndVisible];
}

- (void)dealloc {
  [[GANTracker sharedTracker] stopTracker];
  [window_ release];
  [super dealloc];
}

@end
