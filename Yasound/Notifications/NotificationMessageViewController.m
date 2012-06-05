//
//  NotificationMessageViewController.m
//  Yasound
//
//  Created by matthieu campion on 4/4/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "NotificationMessageViewController.h"
#import "Theme.h"
#import "RadioViewController.h"
#import "AudioStreamManager.h"
#import "NotificationCenterTableViewcCell.h"
#import "FriendsViewController.h"
#import "RadioViewController.h"
#import "MessageWeViewController.h"
#import "ProfileViewController.h"




@implementation NotificationMessageViewController

@synthesize notification;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil notification:(UserNotification*)notif
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.notification = notif;
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

- (void)viewDidLoad
{
    [super viewDidLoad];  
  
  BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MenuBackground" error:nil];    
  self.view.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
  _textView.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
  
    _topBarTitle.title = NSLocalizedString(@"NotificationCenterView_title", nil);
    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);
    
    _textView.text = self.notification.text;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}









- (IBAction)onNowPlayingClicked:(id)sender
{
  RadioViewController* view = [[RadioViewController alloc] initWithRadio:[AudioStreamManager main].currentRadio];
  [self.navigationController pushViewController:view animated:YES];
  [view release];
}

- (IBAction)onMenuBarItemClicked:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}

@end
