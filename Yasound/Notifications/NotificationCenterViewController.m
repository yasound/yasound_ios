//
//  NotificationCenterViewController.m
//  Yasound
//
//  Created by matthieu campion on 4/4/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "NotificationCenterViewController.h"
#import "Theme.h"
#import "RadioViewController.h"
#import "AudioStreamManager.h"
#import "NotificationCenterTableViewcCell.h"
#import "FriendsViewController.h"
#import "RadioViewController.h"
#import "MessageWeViewController.h"
#import "ProfileViewController.h"
#import "NotificationMessageViewController.h"



@implementation NotificationCenterViewController


@synthesize notifications;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
  _tableView.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
  
    _topBarTitle.text = NSLocalizedString(@"NotificationCenterView_title", nil);
    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);

    [[YasoundDataProvider main] userNotificationsWithTarget:self action:@selector(onNotificationsReceived:success:)];
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



- (void)onNotificationsReceived:(ASIHTTPRequest*)req success:(BOOL)success
{   
    if (!success)
    {
        NSLog(@"get user notifications FAILED");
        return;
    }
    
    self.notifications = [NSMutableArray arrayWithArray:[req responseNSObjectsWithClass:[UserNotification class]]];
    
    if (self.notifications == nil)
        NSLog(@"error receiving notifications");
    NSLog(@"%d notifications received", self.notifications.count);
    
    [_tableView reloadData];
}

    

#pragma mark - TableView Source and Delegate




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (self.notifications == nil)
        return 0;
    
    return self.notifications.count;
}






- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
  static NSString *cellIdentifier = @"NotificationCenterTableViewCell";
    
    UserNotification* notif = [self.notifications objectAtIndex:indexPath.row];
  
    NotificationCenterTableViewcCell* cell = (NotificationCenterTableViewcCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  
    if (cell == nil)
    {    
        cell = [[NotificationCenterTableViewcCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier notification:notif];
    }
    else
    {
        [cell updateWithNotification:notif];
    }
  
  return cell;
}


- (void)goToFriendsViewController
{
  FriendsViewController* view = [[FriendsViewController alloc] initWithNibName:@"FriendsViewController" bundle:nil title:NSLocalizedString(@"selection_tab_friends", nil) tabIcon:@"tabIconFavorites.png"];
  [self.navigationController pushViewController:view animated:YES];
  [view release];
}

- (void)goToFriendProfile: (User*)user
{
  ProfileViewController* view = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil user:user];
  [self.navigationController pushViewController:view animated:YES];
  [view release];
}

- (void)goToRadio:(NSNumber*)radioID
{
  [[YasoundDataProvider main] radioWithId:radioID target:self action:@selector(receivedRadio:withInfo:)];
}

- (void)goToMessageWebView:(NSString*)url
{
  MessageWeViewController* view = [[MessageWeViewController alloc] initWithNibName:@"MessageWeViewController" bundle:nil url:url];
  [self.navigationController pushViewController:view animated:YES];
  [view release];
}

- (void)receivedRadio:(Radio*)radio withInfo:(NSDictionary*)info
{
  if (!radio)
    return;
  
  RadioViewController* view = [[RadioViewController alloc] initWithRadio:radio];
  [self.navigationController pushViewController:view animated:YES];
  [view release]; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
    
    
    
    UserNotification* notif = [self.notifications objectAtIndex:indexPath.row];
    
    NSLog(@"select notif %@", notif.type);
    NSLog(@"params %@", notif.params);
    
    [notif setReadBool:YES];
    
    // consider it as being read 
    NotificationCenterTableViewcCell* cell =  (NotificationCenterTableViewcCell*)[_tableView cellForRowAtIndexPath:indexPath];
    [cell updateWithNotification:notif];
    [[YasoundDataProvider main] updateUserNotification:notif target:self action:@selector(updatedUserNotification:success:)];


    
    
    
    if ([notif.type isEqualToString:APNS_NOTIF_FRIEND_ONLINE])
    {
      NSLog(@"go to friend screen");
      User* user = [[User alloc] init];
      user.id = notif.dest_user_id;
        
      if (user.id != nil)
        [self goToFriendProfile: user];
      else
        [self goToFriendsViewController];
    
        return;
    }
    

    if ([notif.type isEqualToString:APNS_NOTIF_YASOUND_MESSAGE])
    {
        NSString* url = [notif.params objectForKey:@"url"];
        assert(url != nil);
        
        NSLog(@"go to web page %@", url);
        [self goToMessageWebView:url];
        return;
    }
     
    
    if ([notif.type isEqualToString:APNS_NOTIF_USER_MESSAGE])
    {
        NotificationMessageViewController* view = [[NotificationMessageViewController alloc] initWithNibName:@"NotificationMessageViewController" bundle:nil notification:notif];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
        return;
    }

    
    NSNumber* radioID = [notif.params objectForKey:@"radioID"];
    assert(radioID != nil);
    
      NSLog(@"go to radio %@", radioID);
      [self goToRadio:radioID];

    
}



- (void)updatedUserNotification:(ASIHTTPRequest*)req success:(BOOL)success
{
    if (!success)
    {
        NSLog(@"update notification FAILED");
        return;
    }
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle != UITableViewCellEditingStyleDelete)
    return;
  
    UserNotification* notif = [self.notifications objectAtIndex:indexPath.row];
    [[YasoundDataProvider main] deleteUserNotification:notif target:self action:@selector(deletedNotification:success:)];

    
    [self.notifications removeObjectAtIndex:indexPath.row];
  
    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationMiddle];
}



- (void)deletedNotification:(ASIHTTPRequest*)req success:(BOOL)success
{
    if (!success)
    {
        NSLog(@"delete notification FAILED");
        return;
    }
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
