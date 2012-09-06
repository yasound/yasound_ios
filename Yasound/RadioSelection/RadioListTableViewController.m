//
//  RadioListTableViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 19/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "RadioListTableViewController.h"
#import "RadioListTableViewCell.h"
#import "UserListTableViewCell.h"

@interface RadioListTableViewController ()

@end


@implementation RadioListTableViewController

@synthesize listDelegate;
@synthesize radios = _radios;
@synthesize friends = _friends;
@synthesize friendsMode;
@synthesize delayTokens;
@synthesize delay;

- (id)initWithStyle:(UITableViewStyle)style radios:(NSArray*)radios
{
    self = [super initWithStyle:style];
    if (self) 
    {
        self.delayTokens = 2;
        self.delay = 0.15;
        
        self.radios = radios;
        self.friendsMode = NO;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"radioListRowBkgSize2.png"]];
    }
    return self;
}

- (void)setRadios:(NSArray*)radios
{
    _radios = radios;
    [_radios retain];
    
    [self.tableView reloadData];
}

- (void)setFriends:(NSArray*)friends
{
    _friends = friends;
    [_friends retain];
    
    self.friendsMode = YES;
    [self.tableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.friendsMode)
    {
        if (self.friends == nil)
            return 0;
        NSInteger nbRows = self.friends.count / 2;
        if ((self.friends.count % 2) != 0)
            nbRows++;
        return nbRows;
    }
    
    if (self.radios == nil)
        return 0;
    
    NSInteger nbRows = self.radios.count / 2;
    if ((self.radios.count % 2) != 0)
        nbRows++;
    return nbRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.friendsMode)
    {
        return 164.f;
    }
    
    return 156.f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.friendsMode)
        return [self userCellForRowAtIndexPath:indexPath tableView:tableView];
    
    return [self radioCellForRowAtIndexPath:indexPath tableView:tableView];
}


- (UITableViewCell*)radioCellForRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView*)tableView
{
    static NSString* cellRadioIdentifier = @"RadioListTableViewCell";

    RadioListTableViewCell* cell = (RadioListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellRadioIdentifier];
    
    NSInteger radioIndex = indexPath.row * 2;
    
    Radio* radio1 = [self.radios objectAtIndex:radioIndex];
    Radio* radio2 = nil;
    if (radioIndex+1 < self.radios.count)
        radio2 = [self.radios objectAtIndex:radioIndex+1];
    
    NSArray* radiosForRow = [NSArray arrayWithObjects:radio1, radio2, nil];
    
    if (cell == nil)
    {
        CGFloat delay = 0;
        if (self.delayTokens > 0)
            delay = self.delay;
        
        cell = [[RadioListTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellRadioIdentifier radios:radiosForRow delay:delay target:self action:@selector(onRadioClicked:)];
        
        self.delayTokens--;
        self.delay += 0.3;
    }
    else
    {
        [cell updateWithRadios:radiosForRow target:self action:@selector(onRadioClicked:)];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}




- (UITableViewCell*)userCellForRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView*)tableView
{
    static NSString* cellUserIdentifier = @"UserListTableViewCell";
    
    UserListTableViewCell* cell = (UserListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellUserIdentifier];
    
    NSInteger userIndex = indexPath.row * 2;
    
    User* user1 = [self.friends objectAtIndex:userIndex];
    User* user2 = nil;
    if (userIndex+1 < self.friends.count)
        user2 = [self.friends objectAtIndex:userIndex+1];
    
    NSArray* usersForRow = [NSArray arrayWithObjects:user1, user2, nil];
    
    if (cell == nil)
    {
        CGFloat delay = 0;
        if (self.delayTokens > 0)
            delay = self.delay;
        
        cell = [[UserListTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellUserIdentifier users:usersForRow delay:delay target:self action:@selector(onUserClicked:)];
        
        self.delayTokens--;
        self.delay += 0.3;
    }
    else
    {
        [cell updateWithUsers:usersForRow target:self action:@selector(onUserClicked:)];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}





//- (void)cellFadeIn:(NSTimer*)timer
//{
//    RadioListTableViewCell* cell = timer.userInfo;
//    cell
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
- (void)onRadioClicked:(Radio*)radio
{
    // call delegate with selected radio
    [self.listDelegate radioListDidSelect:radio];
}

- (void)onUserClicked:(User*)user
{
    // call delegate with selected radio
    [self.listDelegate friendListDidSelect:user];
}

@end
