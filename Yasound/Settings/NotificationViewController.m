//
//  NotificationViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 05/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationManager.h"
#import "NotificationViewCell.h"
#import "YasoundDataProvider.h"
#import "Theme.h"

#define SECTION_COUNT 2
#define SECTION_GENERAL 0
#define SECTION_RADIO 1

#define ROW_GENERAL_COUNT 2
#define ROW_GENERAL_FRIEND_ONLINE 0
#define ROW_GENERAL_FRIEND_CREATE_RADIO 1

#define ROW_RADIO_COUNT 6
#define ROW_RADIO_USER_ENTER 0
#define ROW_RADIO_FRIEND_ENTER 1
#define ROW_RADIO_MESSAGE_POSTED 2
#define ROW_RADIO_SONG_LIKED 3
#define ROW_RADIO_SHARED 4
#define ROW_RADIO_FAVORITE 5




@interface NotificationViewController ()

@end

@implementation NotificationViewController










- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    
  [[YasoundDataProvider main] apnsPreferencesWithTarget:self action:@selector(receivedAPNsPreferences:withInfo:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (void)receivedAPNsPreferences:(APNsPreferences*)prefs withInfo:(NSDictionary*)info
{
  if (!prefs)
    return;
  
  [[NotificationManager main] updateWithAPNsPreferences:prefs];
  [_tableView reloadData];
}










#pragma mark - TableView Source and Delegate



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_COUNT;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
//    return [NotificationManager main].notifications.count;
    if (section == SECTION_GENERAL)
        return ROW_GENERAL_COUNT;
    if (section == SECTION_RADIO)
        return ROW_RADIO_COUNT;
    return 0;
}





- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSInteger section = indexPath.section;
//    NSInteger nbRows = [NotificationManager main].notifications.count;
    NSInteger nbRows = 0;
    if (section == SECTION_GENERAL)
        nbRows = ROW_GENERAL_COUNT;
    else if (section == SECTION_RADIO)
        nbRows = ROW_RADIO_COUNT;
    
    if (nbRows == 1)
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowSingle.png"]];
        cell.backgroundView = view;
        [view release];
    }
    else if (indexPath.row == 0)
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowFirst.png"]];
        cell.backgroundView = view;
        [view release];
    }
    else if (indexPath.row == (nbRows -1))
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowLast.png"]];
        cell.backgroundView = view;
        [view release];
    }
    else
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowInter.png"]];
        cell.backgroundView = view;
        [view release];
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString* CellIdentifier = @"CellNotif";

//    NSArray* keys = [[NotificationManager main].notifications allKeys];
//    NSString* notifIdentifier = [keys objectAtIndex:indexPath.row];
    
    NSString* notifIdentifier = nil;
    if (indexPath.section == SECTION_GENERAL)
    {
        if (indexPath.row == ROW_GENERAL_FRIEND_ONLINE)
            notifIdentifier = NOTIF_FRIEND_ONLINE;
        else if (indexPath.row == ROW_GENERAL_FRIEND_CREATE_RADIO)
            notifIdentifier = NOTIF_NEW_FRIEND_RADIO;
    }
    else if (indexPath.section == SECTION_RADIO)
    {
        if (indexPath.row == ROW_RADIO_USER_ENTER)
            notifIdentifier = NOTIF_USER_ENTERS;
        else if (indexPath.row == ROW_RADIO_FRIEND_ENTER)
            notifIdentifier = NOTIF_FRIEND_ENTERS;
        else if (indexPath.row == ROW_RADIO_FAVORITE)
            notifIdentifier = NOTIF_SUBSCRIPTION;
        else if (indexPath.row == ROW_RADIO_MESSAGE_POSTED)
            notifIdentifier = NOTIF_POST_RECEIVED;
        else if (indexPath.row == ROW_RADIO_SONG_LIKED)
            notifIdentifier = NOTIF_LIKE;
        else if (indexPath.row == ROW_RADIO_SHARED)
            notifIdentifier = NOTIF_RADIO_SHARED;
    }
                                 
    NotificationViewCell* cell = (NotificationViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[NotificationViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier notifIdentifier:notifIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
        [cell update:notifIdentifier];
    
    return cell;
}



//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    NSString* title = nil;
//    
//    if (section == SECTION_GENERAL)
//    {
//        title = NSLocalizedString(@"NotifSectionGeneral", nil);
//    }
//    else if (section == SECTION_RADIO)
//    {
//        title = NSLocalizedString(@"NotifSectionRadio", nil);
//    }
//    
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Menu.MenuSection" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    
//    UIImage* image = [sheet image];
//    CGFloat height = image.size.height;
//    UIImageView* view = [[UIImageView alloc] initWithImage:image];
//    view.frame = CGRectMake(0, 0, tableView.bounds.size.width, height);
//    
//    sheet = [[Theme theme] stylesheetForKey:@"Menu.MenuSectionTitle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    UILabel* label = [sheet makeLabel];
//    label.text = title;
//    [view addSubview:label];
//    
//    return view;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{    
    return 22;
}












#pragma mark - TopBarDelegate

- (BOOL)topBarItemClicked:(TopBarItemId)itemId
{
    self.itemId = itemId;
    
    APNsPreferences* prefs = [[NotificationManager main] APNsPreferences];
    [[YasoundDataProvider main] setApnsPreferences:prefs target:self action:@selector(onAcknowledge:obj:)];

    //LBEBUG : bug selector is not called!
//    return NO;
    
    return YES;
}

- (void)onAcknowledge:(id)obj1 obj2:(id)obj2
{
    DLog(@"ok");
    [self.topbar runItem:self.itemId];
}


@end
