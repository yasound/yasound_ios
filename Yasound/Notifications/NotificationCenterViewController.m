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
#import "RootViewController.h"
#import "LoadingCell.h"

@implementation NotificationCenterViewController


@synthesize notifications;
@synthesize notificationsDictionary;




#define WALL_WAITING_ROW_HEIGHT 44
#define NOTIFICATIONS_LIMIT 25



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        _waitingForPreviousEvents = NO;
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
    
    _waitingForPreviousEvents = NO;

  
  BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MenuBackground" error:nil];    
  self.view.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
  _tableView.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
  
    _topBarTitle.text = NSLocalizedString(@"NotificationCenterView_title", nil);
    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);

    [[YasoundDataProvider main] userNotificationsWithTarget:self action:@selector(onNotificationsReceived:success:)  limit:NOTIFICATIONS_LIMIT offset:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iOsNotificationReceived:) name:NOTIF_HANDLE_IOS_NOTIFICATION object:nil];
}


- (void)iOsNotificationReceived:(NSNotification*)notif
{
    // a new notification has been received, request everthing again. It's simpler, don't want to loose time with cell's comparaison 
    NSInteger limit = 25;
    if (self.notifications != nil)
        limit = self.notifications.count;
    
    [[YasoundDataProvider main] userNotificationsWithTarget:self action:@selector(onNotificationsReceived:success:)  limit:limit offset:0];    
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
    [self removeWaitingEventRow];

    if (!success)
    {
        NSLog(@"get user notifications FAILED");
        return;
    }
    
    Container* container = [req responseObjectsWithClass:[UserNotification class]];
    NSArray* newNotifications = container.objects;
    
    if (newNotifications == nil)
        NSLog(@"error receiving notifications");
    NSLog(@"%d notifications received", newNotifications.count);
    
    if ((newNotifications == nil) || (self.notifications == nil))
    {
        // reload all
        self.notifications = [NSMutableArray arrayWithArray:newNotifications];
        self.notificationsDictionary = [NSMutableDictionary dictionary];
        for (UserNotification* notif in self.notifications)
        {
            [self.notificationsDictionary setObject:notif forKey:notif._id];
        }
        
        [_tableView reloadData];
    }
    
    // insert new ones
    else
    {
        for (NSInteger i = newNotifications.count -1; i >= 0; i--)
        {
            UserNotification* notif = [newNotifications objectAtIndex:i];
            
            UserNotification* retreived = [self.notificationsDictionary objectForKey:notif._id];
            if (retreived != nil)
                continue;
            
            // not inserted yet. do it now
            [self.notifications insertObject:notif atIndex:0];
            [self.notificationsDictionary setObject:notif forKey:notif._id];
            [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
        }
    }
    
}


- (void)onNotificationsAdded:(ASIHTTPRequest*)req success:(BOOL)success
{   
    [self removeWaitingEventRow];
    
    if (!success)
    {
        NSLog(@"get user notifications FAILED");
        return;
    }
    
    Container* container = [req responseObjectsWithClass:[UserNotification class]];
    NSArray* newNotifications = container.objects;

    if (newNotifications == nil)
        return;
    
    // insert new ones
    for (NSInteger i = 0; i < newNotifications.count; i++)
    {
        UserNotification* notif = [newNotifications objectAtIndex:i];
        [self.notifications addObject:notif];
        [self.notificationsDictionary setObject:notif forKey:notif._id];
        [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.notifications.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
    }
    
    
}






- (void)showWaitingEventRow
{
    if (_waitingForPreviousEvents)
        return;
    
    _waitingForPreviousEvents = YES;
    // #FIXME: todo...
    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.notifications.count inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)removeWaitingEventRow
{
    if (!_waitingForPreviousEvents)
        return;
    
    _waitingForPreviousEvents = NO;
    // #FIXME: todo...
    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.notifications.count inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}


    

#pragma mark - TableView Source and Delegate




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSInteger nbRows = 0;
    
    if (self.notifications == nil)
        nbRows = 0;
    else
        nbRows = self.notifications.count;
    
    if (_waitingForPreviousEvents)
        nbRows++;

    return nbRows;
}






- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
  static NSString *cellIdentifier = @"NotificationCenterTableViewCell";
    
    
    // waiting cell
    if (_waitingForPreviousEvents && indexPath.row == self.notifications.count)
    {
        static NSString* LoadingCellIdentifier = @"NotificationCenterWaitingCell";
        
        LoadingCell* cell = (LoadingCell*)[tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier];
        if (cell == nil)
        {
            cell = [[[LoadingCell alloc] initWithFrame:CGRectZero reuseIdentifier:LoadingCellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;            
        }
        return cell;
    }
    

    
    
    
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

    if (![notif isReadBool])
    {
        [notif setReadBool:YES];
        
        // consider it as being read 
        NotificationCenterTableViewcCell* cell =  (NotificationCenterTableViewcCell*)[_tableView cellForRowAtIndexPath:indexPath];
        [cell updateWithNotification:notif];
        [[YasoundDataProvider main] updateUserNotification:notif target:self action:@selector(updatedUserNotification:success:)];
        
        
        
        return;
    }
    
    
    
    if ([notif.type isEqualToString:APNS_NOTIF_FRIEND_ONLINE])
    {
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
    
    if (notif.from_radio_id != nil)
    {
        NSLog(@"go to radio %@", notif.from_radio_id);
        [self goToRadio:notif.from_radio_id];
        return;
    }
        
    NSNumber* radioID = [notif.params objectForKey:@"radioID"];
    if (radioID != nil)
    {
      NSLog(@"go to radio %@", radioID);
      [self goToRadio:radioID];
    }

    
}



- (void)updatedUserNotification:(ASIHTTPRequest*)req success:(BOOL)success
{
    if (!success)
    {
        NSLog(@"update notification FAILED");
        return;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_HANDLE_IOS_NOTIFICATION object:nil]; 
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle != UITableViewCellEditingStyleDelete)
    return;
  
    UserNotification* notif = [self.notifications objectAtIndex:indexPath.row];
    [[YasoundDataProvider main] deleteUserNotification:notif target:self action:@selector(deletedNotification:success:)];

    
    [self.notifications removeObjectAtIndex:indexPath.row];
    [self.notificationsDictionary removeObjectForKey:notif._id];
  
    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationMiddle];
}



- (void)deletedNotification:(ASIHTTPRequest*)req success:(BOOL)success
{
    if (!success)
    {
        NSLog(@"delete notification FAILED");
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_HANDLE_IOS_NOTIFICATION object:nil];
    [_tableView reloadData];
}


- (void)deletedAllNotifications:(ASIHTTPRequest*)req success:(BOOL)success  
{
    if (!success)
    {
        NSLog(@"delete all notifications FAILED");
        return;
    }

    NSLog(@"delete all notifications OK");

    [self.notifications removeAllObjects];
    [self.notificationsDictionary removeAllObjects];
    [_tableView reloadData];

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_HANDLE_IOS_NOTIFICATION object:nil];     
}







- (IBAction)onNowPlayingClicked:(id)sender
{
  RadioViewController* view = [[RadioViewController alloc] initWithRadio:[AudioStreamManager main].currentRadio];
  [self.navigationController pushViewController:view animated:YES];
  [view release];
}


- (IBAction)onItemTrashClicked:(id)sender
{
    NSString* title = NSLocalizedString(@"NotificationCenterView_alert_title", nil);
    NSString* message = NSLocalizedString(@"NotificationCenterView_alert_message", nil);
    _alertTrash = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Navigation_cancel", nil) otherButtonTitles:@"OK", nil];
    [_alertTrash show];
    [_alertTrash release];  
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((alertView == _alertTrash) && (buttonIndex == 1))
    {
        [[YasoundDataProvider main] deleteAllUserNotificationsWithTarget:self action:@selector(deletedAllNotifications:success:)];
        return;
    }
}


- (IBAction)onMenuBarItemClicked:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}






- (void)askForPreviousEvents
{
    NSLog(@"ask for previous events");
    if (_waitingForPreviousEvents)
        return;
    
    [[YasoundDataProvider main] userNotificationsWithTarget:self action:@selector(onNotificationsAdded:success:)  limit:NOTIFICATIONS_LIMIT offset:self.notifications.count];
    
    [self showWaitingEventRow];
}





#pragma mark - UIScrollViewDelegate


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_waitingForPreviousEvents)
    {
        float offset = scrollView.contentOffset.y;
        float contentHeight = scrollView.contentSize.height;
        float viewHeight = scrollView.bounds.size.height;
        
        if ((offset > 0) && (offset + viewHeight > contentHeight + WALL_WAITING_ROW_HEIGHT))
        {
            [self askForPreviousEvents];
        }
    }
}





@end
