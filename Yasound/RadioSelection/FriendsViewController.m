//
//  FriendsViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 18/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "FriendsViewController.h"
#import "RadioViewController.h"
#import "AudioStreamManager.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "ActivityModelessSpinner.h"
#import "UserTableViewCell.h"
#import "YasoundDataCache.h"
#import "ProfileViewController.h"

#import "YasoundSessionManager.h"

#define SHOW_INVITE_BUTTON 1

@implementation FriendsViewController


//#define FAKE_USERS

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabIcon:(NSString*)tabIcon
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
      _updateTimer = nil;
      _selectedFriend = nil;
#ifdef FAKE_USERS
        _friends_online = [[NSMutableArray alloc] init];
        _friends_offline = [[NSMutableArray alloc] init];
        for (int i = 0; i < 10; i++)
        {
            User* user = [[User alloc] init];
            user.username = [NSString stringWithFormat:@"username %d", i];
            user.password = [NSString stringWithFormat:@"password %d", i];
            user.name = [NSString stringWithFormat:@"name %d", i];
            user.api_key = [NSString stringWithFormat:@"api_key %d", i];
            user.email = [NSString stringWithFormat:@"email %d", i];
            user.current_radio = [YasoundDataProvider main].radio;
            user.own_radio = [YasoundDataProvider main].radio;
            
            [_friends_online addObject:user];
            [_friends_offline addObject:user];
        }
#else
        _friends_online = nil;
        _friends_offline = nil;
#endif
    }
    return self;
}

- (void)dealloc
{
  [_tableView release];
  [_toolbar release];
  [_toolbarTitle release];
  [_nowPlayingButton release];
  [_cellInviteFacebook release];
  [_cellInviteFacebookLabel release];
  [_cellInviteTwitter release];
  [_cellInviteTwitterLabel release];
  [super dealloc];
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
    
    _toolbarTitle.text = NSLocalizedString(@"FriendsView_title", nil);
    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
  
  _cellInviteFacebookLabel.text = NSLocalizedString(@"InviteFacebookFriends_button_text", nil);
  _cellInviteTwitterLabel.text = NSLocalizedString(@"InviteTwitterFriends_button_text", nil);
}

- (void)viewDidUnload
{  
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)updateFriends
{
#ifndef FAKE_USERS
    [[ActivityModelessSpinner main] addRef];
    [[YasoundDataCache main] requestFriendsWithTarget:self action:@selector(receiveFriends:info:)];
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([AudioStreamManager main].currentRadio == nil)
        _nowPlayingButton.enabled = NO;
    
    [self updateFriends];
    
    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
  if (_updateTimer)
    [_updateTimer invalidate];
}

- (void)onTimer:(NSTimer*)timer
{
    [self updateFriends];
}

- (void)receiveFriends:(NSArray*)friends info:(NSDictionary*)info
{
    NSError* error = [info valueForKey:@"error"];
    if (error)
    {
        NSLog(@"can't get friends: %@", error.domain);
        return;
    }
    
    NSMutableArray* online = [[NSMutableArray alloc] init];
    NSMutableArray* offline = [[NSMutableArray alloc] init];
    for (User* f in friends)
    {
        if (f.current_radio)
            [online addObject:f];
        else
            [offline addObject:f];
    }
    
    _friends_online = online;
    _friends_offline = offline;
    
    [[ActivityModelessSpinner main] removeRef];
    [_tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}











#pragma mark - TableView Source and Delegate

#if SHOW_INVITE_BUTTON

#define SECTION_INVITE_BUTTON 0
#define SECTION_ONLINE 1
#define SECTION_OFFLINE 2

#else

#define SECTION_ONLINE 0
#define SECTION_OFFLINE 1

#endif



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#if SHOW_INVITE_BUTTON
    return 3;
#endif
  
  return 2;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
#if SHOW_INVITE_BUTTON
    if (section == SECTION_INVITE_BUTTON)
    {
      int count = 0;
      if ([[YasoundSessionManager main] getFacebookManager])
        count ++;
      if ([[YasoundSessionManager main] getTwitterManager])
        count ++;
      return count;
    }
    else if (section == SECTION_ONLINE)
    {
        if (!_friends_online)
            return 0;
        return _friends_online.count;
    }
    else if (section == SECTION_OFFLINE)
    {
        if (!_friends_offline)
            return 0;
        return _friends_offline.count;
    }
    else 
        return 0;
#else
  
  if (section == SECTION_ONLINE)
  {
    if (!_friends_online)
      return 0;
    return _friends_online.count;
  }
  else if (section == SECTION_OFFLINE)
  {
    if (!_friends_offline)
      return 0;
    return _friends_offline.count;
  }
  else 
    return 0;
  
#endif
}





- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
#if SHOW_INVITE_BUTTON
    if (section == SECTION_INVITE_BUTTON)
        return 8;
#endif
    
    return 22;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
#if SHOW_INVITE_BUTTON
    if (section == SECTION_INVITE_BUTTON)
        return 0;
#endif    
  
    return 22;
}






- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString* title = nil;

#if SHOW_INVITE_BUTTON
    if (section == SECTION_INVITE_BUTTON)
    {
        UIView* view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        return view;
    }
    else if (section == SECTION_ONLINE)
    {
        title = NSLocalizedString(@"Online", nil);
    }
    else if (section == SECTION_OFFLINE)
    {
        title = NSLocalizedString(@"Offline", nil);
    }
#else
  if (section == SECTION_ONLINE)
  {
    title = NSLocalizedString(@"Online", nil);
  }
  else if (section == SECTION_OFFLINE)
  {
    title = NSLocalizedString(@"Offline", nil);
  }
#endif
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MenuSection" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    
    UIImage* image = [sheet image];
    CGFloat height = image.size.height;
    UIImageView* view = [[UIImageView alloc] initWithImage:image];
    view.frame = CGRectMake(0, 0, tableView.bounds.size.width, height);
    
    sheet = [[Theme theme] stylesheetForKey:@"MenuSectionTitle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = title;
    [view addSubview:label];
    
    return view;
}



- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}






- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
#if SHOW_INVITE_BUTTON
    if (indexPath.section == SECTION_INVITE_BUTTON)
    {
      id tab[2];
      int i = 0;
      if ([[YasoundSessionManager main] getFacebookManager])
        tab[i++] = _cellInviteFacebook;
      if ([[YasoundSessionManager main] getTwitterManager])
        tab[i++] = _cellInviteTwitter;
      NSInteger rowIndex = indexPath.row;
        return tab[rowIndex];
    }
#endif
    
    static NSString *cellIdentifier = @"UserTableViewCell";
    
    NSInteger sectionIndex = indexPath.section;
    NSInteger rowIndex = indexPath.row;
    
    if (sectionIndex > SECTION_OFFLINE || !_friends_online || !_friends_offline)
        return nil;
    NSArray* friends = ((sectionIndex == SECTION_ONLINE) ? _friends_online : _friends_offline);
    
    User* friend = [friends objectAtIndex:rowIndex];

    
    
    UserTableViewCell* cell = (UserTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {    
        cell = [[UserTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier rowIndex:rowIndex user:friend];
    }
    else
        [cell updateWithUser:friend rowIndex:rowIndex];
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#if SHOW_INVITE_BUTTON
    if (indexPath.section == SECTION_INVITE_BUTTON)
    {
      int i = indexPath.row;
      if ([[YasoundSessionManager main] getFacebookManager] && !i--)
        [self inviteFacebookButtonClicked:nil];
      else if ([[YasoundSessionManager main] getTwitterManager] && !i--)
        [self inviteTwitterButtonClicked:nil];
      else
      {
        // we should never get there!
        assert(0);
      }
      return;
    }
#endif

    UserTableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    _selectedFriend = cell.user;

    ProfileViewController* view = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil user:_selectedFriend];
    [self.navigationController pushViewController:view animated:YES];
    [view release];

//    UserTableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
//    
//    _selectedFriend = cell.user;
//    Radio* currentRadio = nil;
//    Radio* ownRadio = nil;
//    if (_selectedFriend.current_radio)
//        currentRadio = _selectedFriend.current_radio;
//    if (_selectedFriend.own_radio && [_selectedFriend.own_radio.ready boolValue])
//        ownRadio = _selectedFriend.own_radio;
//  
//  if (!currentRadio && !ownRadio)
//    return;
//  
//  if (currentRadio && ownRadio && [currentRadio.id intValue] != [ownRadio.id intValue])
//  {
//    UIActionSheet* joiinRadioSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"GoTo_FriendRadio_Title", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"GoTo_FriendRadioCancel_Label", nil)destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"GoTo_FriendCurrentRadio_Label", nil), NSLocalizedString(@"GoTo_FriendRadio_Label", nil), nil];
//    joiinRadioSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//    [joiinRadioSheet showInView:self.view];
//  }
//  else if (currentRadio)
//  {
//    RadioViewController* view = [[RadioViewController alloc] initWithRadio:currentRadio];
//    [self.navigationController pushViewController:view animated:YES];
//    [view release];  
//  }
//  else if (ownRadio)
//  {
//    RadioViewController* view = [[RadioViewController alloc] initWithRadio:ownRadio];
//    [self.navigationController pushViewController:view animated:YES];
//    [view release];  
//  }  
}







#pragma mark - ActionSheet Delegate


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
  NSLog(@"action sheet button %d", buttonIndex);
  Radio* currentRadio = nil;
  Radio* ownRadio = nil;
  if (_selectedFriend.current_radio)
    currentRadio = _selectedFriend.current_radio;
  if (_selectedFriend.own_radio && [_selectedFriend.own_radio.ready boolValue])
    ownRadio = _selectedFriend.own_radio;
  
  if (buttonIndex == 0)
  {
    assert(currentRadio);
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:currentRadio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
  }
  else if (buttonIndex == 1)
  {
    assert(ownRadio);
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:ownRadio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
  }
}





#pragma mark - IBActions

- (IBAction)nowPlayingClicked:(id)sender
{
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:[AudioStreamManager main].currentRadio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (IBAction)menuBarItemClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)inviteFacebookButtonClicked:(id)sender
{
  [[FacebookSessionManager facebook] inviteFriends];
}

- (IBAction)inviteTwitterButtonClicked:(id)sender
{
    [[TwitterSessionManager twitter] inviteFriends:self.view];
}


@end
