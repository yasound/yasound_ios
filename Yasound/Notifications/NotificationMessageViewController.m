//
//  NotificationMessageViewController.m
//  Yasound
//
//  Created by matthieu campion on 4/4/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "NotificationMessageViewController.h"
#import "Theme.h"
#import "AudioStreamManager.h"
#import "NotificationCenterTableViewcCell.h"
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



- (NSString*) dateToString:(NSDate*)d
{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    NSDate* now = [NSDate date];
    NSDateComponents* todayComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:now];
    NSDateComponents* refComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:d];
    
    if (todayComponents.year == refComponents.year && todayComponents.month == refComponents.month && todayComponents.day == refComponents.day)
    {
        // today: show time
        [dateFormat setDateFormat:@"HH:mm"];
    }
    else
    {
        // not today: show date
        [dateFormat setDateFormat:@"dd/MM, HH:mm"];
    }
    
    NSString* s = [dateFormat stringFromDate:d];
    [dateFormat release];
    return s;
}


- (void)viewDidLoad
{
    [super viewDidLoad];  
  
  BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Menu.MenuBackground" error:nil];    
  self.view.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
  _textView.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
  
    _topBarTitle.title = NSLocalizedString(@"NotificationCenterView_title", nil);
    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);
    
    _textView.text = [NSString stringWithFormat:@"%@: %@\n%@: %@\n%@\n\n%@",
                      NSLocalizedString(@"NotificationMessageView_from", nil),
                      self.notification.from_user_name,
                      NSLocalizedString(@"NotificationMessageView_from_radio", nil),
                      self.notification.from_radio_name,
                       [self dateToString:self.notification.date],
                      self.notification.text];

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









//- (IBAction)onNowPlayingClicked:(id)sender
//{
//  RadioViewController* view = [[RadioViewController alloc] initWithRadio:[AudioStreamManager main].currentRadio];
//  [self.navigationController pushViewController:view animated:YES];
//  [view release];
//}

//- (IBAction)onMenuBarItemClicked:(id)sender
//{
//  [self.navigationController popViewControllerAnimated:YES];
//}

@end
