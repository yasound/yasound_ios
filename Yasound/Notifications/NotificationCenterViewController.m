//
//  NotificationCenterViewController.m
//  Yasound
//
//  Created by matthieu campion on 4/4/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "NotificationCenterViewController.h"
#import "Theme.h"
#import "AudioStreamManager.h"
#import "NotificationCenterTableViewcCell.h"
#import "MessageWeViewController.h"
#import "ProfilViewController.h"
#import "NotificationMessageViewController.h"
#import "RootViewController.h"
#import "LoadingCell.h"
#import "YasoundDataProvider.h"

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

    [self.topBar showTrashItem];
  
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Common.gradient" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
  
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
        DLog(@"get user notifications FAILED");
        return;
    }
    
    Container* container = [req responseObjectsWithClass:[UserNotification class]];
    NSArray* newNotifications = container.objects;
    
    if (newNotifications == nil)
        DLog(@"error receiving notifications");
    DLog(@"%d notifications received", newNotifications.count);
    
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
        DLog(@"get user notifications FAILED");
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46.f;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.cell" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImageView* view = [sheet makeImage];
    cell.backgroundView = view;
    [view autorelease];
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
    //LBDEBUG TODO : kess kon fait ici maintenant?
    assert(0);
    
//  FriendsViewController* view = [[FriendsViewController alloc] initWithNibName:@"FriendsViewController" bundle:nil title:NSLocalizedString(@"selection_tab_friends", nil) tabIcon:@"tabIconFavorites.png"];
//  [self.navigationController pushViewController:view animated:YES];
//  [view release];
}

- (void)goToFriendProfile: (User*)user
{
  ProfilViewController* view = [[ProfilViewController alloc] initWithNibName:@"ProfilViewController" bundle:nil forUser:user showTabs:NO];
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

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:radio];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
    
    UserNotification* notif = [self.notifications objectAtIndex:indexPath.row];
    
    DLog(@"select notif %@", notif.type);
    DLog(@"params %@", notif.params);

    if (![notif isReadBool])
    {
        [notif setReadBool:YES];
        
        // consider it as being read 
        NotificationCenterTableViewcCell* cell =  (NotificationCenterTableViewcCell*)[_tableView cellForRowAtIndexPath:indexPath];
        [cell updateWithNotification:notif];
        [[YasoundDataProvider main] updateUserNotification:notif target:self action:@selector(updatedUserNotification:success:)];
        
        return;
    }
    
    
    
    if ([notif.type isEqualToString:APNS_NOTIF_FRIEND_ONLINE]
        || [notif.type isEqualToString:APNS_NOTIF_SONG_LIKED]
        || [notif.type isEqualToString:APNS_NOTIF_RADIO_IN_FAVORITES]
        || [notif.type isEqualToString:APNS_NOTIF_RADIO_SHARED]
        || [notif.type isEqualToString:APNS_NOTIF_FRIEND_CREATED_RADIO]
        || [notif.type isEqualToString:APNS_NOTIF_USER_IN_RADIO]
        || [notif.type isEqualToString:APNS_NOTIF_FRIEND_IN_RADIO]
        )
    {
        [self goToFriendsViewController];
        return;
    }
    

    if ([notif.type isEqualToString:APNS_NOTIF_YASOUND_MESSAGE])
    {
        NSString* url = [notif.params objectForKey:@"url"];
        assert(url != nil);
        
        DLog(@"go to web page %@", url);
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

    
    if ([notif.type isEqualToString:APNS_NOTIF_MESSAGE_POSTED])
    {
        [self goToRadio:[YasoundDataProvider main].radio.id];
        return;
    }
    
    
    if (notif.from_radio_id != nil)
    {
        DLog(@"go to radio %@", notif.from_radio_id);
        [self goToRadio:notif.from_radio_id];
        return;
    }
        
    NSNumber* radioID = [notif.params objectForKey:@"radioID"];
    if (radioID != nil)
    {
      DLog(@"go to radio %@", radioID);
      [self goToRadio:radioID];
    }

    
}



- (void)updatedUserNotification:(ASIHTTPRequest*)req success:(BOOL)success
{
    if (!success)
    {
        DLog(@"update notification FAILED");
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
        DLog(@"delete notification FAILED");
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_HANDLE_IOS_NOTIFICATION object:nil];
    [_tableView reloadData];
}


- (void)deletedAllNotifications:(ASIHTTPRequest*)req success:(BOOL)success  
{
    if (!success)
    {
        DLog(@"delete all notifications FAILED");
        return;
    }

    DLog(@"delete all notifications OK");

    [self.notifications removeAllObjects];
    [self.notificationsDictionary removeAllObjects];
    [_tableView reloadData];

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_HANDLE_IOS_NOTIFICATION object:nil];     
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



- (void)askForPreviousEvents
{
    DLog(@"ask for previous events");
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







#pragma mark - TopBarDelegate

- (BOOL)topBarItemClicked:(TopBarItemId)itemId
{
    if (itemId == TopBarItemTrash)
    {
        NSString* title = NSLocalizedString(@"NotificationCenterView_alert_title", nil);
        NSString* message = NSLocalizedString(@"NotificationCenterView_alert_message", nil);
        _alertTrash = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Navigation_cancel", nil) otherButtonTitles:@"OK", nil];
        [_alertTrash show];
        [_alertTrash release];
        
        return YES;
    }
    
    else if (itemId == TopBarItemNotif)
    {
        return NO;
    }
        
    
    return YES;
}



@end
