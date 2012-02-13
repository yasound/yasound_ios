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
#import "YasoundDataProvider.h"
#import "ActivityModelessSpinner.h"
#import "UserTableViewCell.h"

#import "FacebookSessionManager.h"

@implementation FriendsViewController


//#define FAKE_USERS

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabIcon:(NSString*)tabIcon
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
      _updateTimer = nil;
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
  [_cellInvite release];
  [_cellInviteLabel release];
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
  
    _cellInviteLabel.text = NSLocalizedString(@"InviteFriends_button_text", nil);
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
    [[YasoundDataProvider main] friendsWithTarget:self action:@selector(receiveFriends:info:)];
    [[ActivityModelessSpinner main] addRef];
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
        else if (f.own_radio && [f.own_radio.ready boolValue])
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


#define SECTION_INVITE_BUTTON 0
#define SECTION_ONLINE 1
#define SECTION_OFFLINE 2


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == SECTION_INVITE_BUTTON)
    {
        return 1;
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
}





- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_INVITE_BUTTON)
        return 8;
    
//    return 33;
    return 22;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == SECTION_INVITE_BUTTON)
        return 0;
    
    return 22;
}






- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString* title = nil;
    
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





- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.section == SECTION_INVITE_BUTTON)
        return nil;

    NSInteger rowIndex = indexPath.row;
    UIImageView* imageView = nil;
    
    // cell background
    if (rowIndex & 1)
    {
        imageView = [[[BundleFileManager main] stylesheetForKey:@"RadioSelectionBackgroundLight"  retainStylesheet:YES overwriteStylesheet:NO error:nil] makeImage];
    }
    else
    {
        imageView = [[[BundleFileManager main] stylesheetForKey:@"RadioSelectionBackgroundDark"  retainStylesheet:YES overwriteStylesheet:NO error:nil] makeImage];
    }
    
    cell.backgroundView = imageView;
    
}







- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.section == SECTION_INVITE_BUTTON)
    {
        return _cellInvite;
    }
    
    static NSString *cellIdentifier = @"UserTableViewCell";
    
    NSInteger sectionIndex = indexPath.section;
    NSInteger rowIndex = indexPath.row;
    
    if (sectionIndex > SECTION_OFFLINE || !_friends_online || !_friends_offline)
        return nil;
    NSArray* friends = ((sectionIndex == 1) ? _friends_online : _friends_offline);
    
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
    if (indexPath.section == SECTION_INVITE_BUTTON)
    {
        [self inviteButtonClicked:nil];
        return;
    }
    
    UserTableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    User* u = cell.user;
    Radio* r;
    if (u.current_radio)
        r = u.current_radio;
    else if (u.own_radio && [u.own_radio.ready boolValue])
        r = u.own_radio;
    else
        return;
    
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:r];
    [self.navigationController pushViewController:view animated:YES];
    [view release];  
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

- (IBAction)inviteButtonClicked:(id)sender
{
  [[FacebookSessionManager facebook] inviteFriends];
}


@end
