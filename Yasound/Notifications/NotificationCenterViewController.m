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
#import "YasoundNotifCenter.h"

@implementation NotificationCenterViewController

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
  
  [[YasoundNotifCenter main] addTarget:self action:@selector(notificationAdded:) forEvent:eAPNsNotifAdded];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  [[YasoundNotifCenter main] removeTarget:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)notificationAdded:(APNsNotifInfo*)notif
{
//  [_tableView reloadData];
  NSInteger row = [YasoundNotifCenter main].notifInfos.count - 1;
  [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
}


#pragma mark - TableView Source and Delegate




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
  NSInteger count = [YasoundNotifCenter main].notifInfos.count;
  return count;
}






- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
  static NSString *cellIdentifier = @"NotificationCenterTableViewCell";
  
  NotificationCenterTableViewcCell* cell = (NotificationCenterTableViewcCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  
  APNsNotifInfo* notifInfo = [[YasoundNotifCenter main].notifInfos objectAtIndex:indexPath.row];
  if (cell == nil)
  {    
    cell = [[NotificationCenterTableViewcCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier notifInfo:notifInfo];
  }
  else
  {
    [cell updateWithNotifInfo:notifInfo];
  }
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  APNsNotifInfo* notifInfo = [[YasoundNotifCenter main].notifInfos objectAtIndex:indexPath.row];
  APNsNotifType t = [notifInfo type];
  NSNumber* radioID = [notifInfo radioID];
  NSString* url = [notifInfo url];
  
  switch (t) 
  {
    case eAPNsNotif_FriendOnline:
      NSLog(@"go to friend screen");
      break;
      
    case eAPNsNotif_UserInRadio:
    case eAPNsNotif_FriendInRadio:
    case eAPNsNotif_MessagePosted:
    case eAPNsNotif_SongLiked:
    case eAPNsNotif_RadioInFavorites:
    case eAPNsNotif_RadioShared:
    case eAPNsNotif_FriendCreatedRadio:
      NSLog(@"go to radio %@", radioID);
      break;
      
    case eAPNsNotif_YasoundMessage:
      NSLog(@"go to web page %@", url);
      break;
      
    default:
      break;
  }
  
  [notifInfo setRead:YES];
  
//  RadioSelectionTableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
//  
//  RadioViewController* view = [[RadioViewController alloc] initWithRadio:cell.radio];
//  [self.navigationController pushViewController:view animated:YES];
//  [view release];  
  
  
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle != UITableViewCellEditingStyleDelete)
    return;
  
  APNsNotifInfo* notifInfo = [[YasoundNotifCenter main].notifInfos objectAtIndex:indexPath.row];
  [[YasoundNotifCenter main] deleteNotifInfo:notifInfo];
  
  [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
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
