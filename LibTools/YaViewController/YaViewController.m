//
//  YaViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 26/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "YaViewController.h"
#import "TestFlight.h"
#import "YasoundAppDelegate.h"
#import "AudioStreamManager.h"
#import "RootViewController.h"

@implementation YaViewController

@synthesize didAppearCheckpoint = _didAppearCheckpoint;
@synthesize slideController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.slideController = APPDELEGATE.slideController;
        self.didAppearCheckpoint =  [NSString stringWithFormat:@"%@ viewDidAppear", [self class]];
        
        [self.slideController setAnchorRightRevealAmount:264.0f];
        self.slideController.underLeftWidthLayout = ECFullWidth;
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    
//#ifdef TESTFLIGHT_SDK
//    [TestFlight passCheckpoint:self.didLoadCheckpoint];
//#endif
//}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
#ifdef TESTFLIGHT_SDK
    [TestFlight passCheckpoint:self.didAppearCheckpoint];
#endif
    
    // refresh notifs gui
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_HANDLE_IOS_NOTIFICATION object:nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    //if it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl)
    {
        if (event.subtype == UIEventSubtypeRemoteControlPlay)
            [[AudioStreamManager main] startRadio:[AudioStreamManager main].currentRadio];
        
        else if (event.subtype == UIEventSubtypeRemoteControlPause)
            [[AudioStreamManager main] pauseRadio];
        
        else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause)
            [[AudioStreamManager main] togglePlayPauseRadio];
        
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}









@end
