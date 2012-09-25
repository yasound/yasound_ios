//
//  InviteFacebookFriendsViewController.m
//  Yasound
//
//  Created by mat on 25/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "InviteFacebookFriendsViewController.h"
#import "FacebookFriend.h"
#import "YasoundSessionManager.h"
#import "SessionManager.h"

@interface InviteFacebookFriendsViewController ()

@end

@implementation InviteFacebookFriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _friends = nil;
        _selectedFriends = [[NSMutableSet alloc] init];
        
        _checkmarkImage = [UIImage imageNamed:@"GrayCheckmark.png"];
        [_checkmarkImage retain];
    }
    return self;
}

- (void)dealloc
{
    if (_friends)
        [_friends release];
    if (_selectedFriends)
        [_selectedFriends release];
    
    [_checkmarkImage release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    FacebookSessionManager* manager = [[YasoundSessionManager main] getFacebookManager];
    if (manager)
    {
        [manager setTarget:self];
        [manager requestGetInfo:SRequestInfoFriends];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section > 0)
        return 0;
    if (!_friends)
        return 0;
    return _friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    FacebookFriend* friend = [_friends objectAtIndex:indexPath.row];
    cell.textLabel.text = friend.name;
//    cell.imageView.image = contact.thumbnail;
    BOOL selected = [_selectedFriends containsObject:friend];
    [self checkmark:cell with:selected];
    
    return cell;
}

- (void)checkmark:(UITableViewCell*)cell with:(BOOL)value
{
    if (value)
    {
        UIImageView* checkmark = [[UIImageView alloc] initWithImage:_checkmarkImage];
        cell.accessoryView = checkmark;
        [checkmark release];
    }
    else
        cell.accessoryView = nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [_tableview cellForRowAtIndexPath:indexPath];
    
    FacebookFriend* friend = [_friends objectAtIndex:indexPath.row];
    if ([_selectedFriends containsObject:friend])
    {
        [_selectedFriends removeObject:friend];
        [self checkmark:cell with:NO];
    }
    else
    {
        [_selectedFriends addObject:friend];
        [self checkmark:cell with:YES];
    }
}


#pragma mark - Top bar delegate

- (BOOL)topBarSave
{
    return YES;
}

- (BOOL)topBarCancel
{
    return YES;
}

- (BOOL)shouldShowActionButton
{
    return YES;
}

- (NSString*)titleForActionButton
{
    return NSLocalizedString(@"ContactListPicker.SendButton", nil);
}

- (NSString*)titleForCancelButton
{
    return NSLocalizedString(@"ContactListPicker.CancelButton", nil);
}

- (NSString*)topBarModalTitle
{
    return NSLocalizedString(@"ContactListPickerTitle", nil);
}

- (void)requestDidLoad:(SessionRequestType)requestType data:(NSArray*)data
{
    if (requestType != SRequestInfoFriends)
        return;
    
    NSMutableArray* friends = [NSMutableArray array];
    for (NSDictionary* dict in data)
    {
        FacebookFriend* f = [[FacebookFriend alloc] init];
        f.id = [dict valueForKey:DATA_FIELD_ID];
        f.name = [dict valueForKey:DATA_FIELD_NAME];
        
        [friends addObject:f];
    }
    
    if (_friends)
        [_friends release];
    _friends = friends;
    [_friends retain];
    
    [_selectedFriends removeAllObjects];
    [_selectedFriends addObjectsFromArray:_friends];
    
    [_tableview reloadData];
}

- (void)requestDidFailed:(SessionRequestType)requestType error:(NSError*)error errorMessage:(NSString*)errorMessage
{
    if (requestType != SRequestInfoFriends)
        return;
}


@end
