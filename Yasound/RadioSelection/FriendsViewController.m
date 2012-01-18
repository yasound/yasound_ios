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

@implementation FriendsViewController

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabIcon:(NSString*)tabIcon
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        UIImage* tabImage = [UIImage imageNamed:tabIcon];
        UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:title image:tabImage tag:0];
        self.tabBarItem = theItem;
        [theItem release];     
        
        _friends_online = nil;
        _friends_offline = nil;
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

    _toolbarTitle.text = NSLocalizedString(@"FriendsView_title", nil);
    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);

    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MyYasoundBackground.png"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)updateFriends
{
    [[YasoundDataProvider main] friendsWithTarget:self action:@selector(receiveFriends:info:)];
    [[ActivityModelessSpinner main] addRef];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([AudioStreamManager main].currentRadio == nil)
        _nowPlayingButton.enabled = NO;
    
    [self updateFriends];
    
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
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
        else if (f.own_radio)
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




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section > 1)
        return nil;
    
    UILabel* view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 55)];
    view.text = section == 0 ? @"online" : @"offline";
    return view;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == 0)
    {
        if (!_friends_online)
            return 0;
        return _friends_online.count;
    }
    else if (section == 1)
    {
        if (!_friends_offline)
            return 0;
        return _friends_offline.count;
    }
    else 
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UIView* view = [[UIView alloc] initWithFrame:cell.frame];
    view.backgroundColor = [UIColor clearColor];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"CellSeparator" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImage* image = [sheet image];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    CGRect frame =     CGRectMake(0, cell.frame.size.height - image.size.height -2, sheet.frame.size.width, sheet.frame.size.height);
    imageView.frame = frame;
    [view addSubview:imageView];
    
    cell.backgroundView = view;
    [view release];    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *cellIdentifier = @"UserTableViewCell";
    
    NSInteger sectionIndex = indexPath.section;
    NSInteger rowIndex = indexPath.row;
    
    if (sectionIndex > 1 || !_friends_online || !_friends_offline)
        return nil;
    NSArray* friends = sectionIndex == 0 ? _friends_online : _friends_offline;
    
    User* friend = [friends objectAtIndex:rowIndex];
    
    UserTableViewCell* cell = [[UserTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier rowIndex:rowIndex user:friend];
    return cell;      
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserTableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    User* u = cell.user;
    Radio* r;
    if (u.current_radio)
        r = u.current_radio;
    else if (u.own_radio)
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

@end
