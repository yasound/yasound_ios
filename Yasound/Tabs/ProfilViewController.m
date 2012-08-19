//
//  ProfilViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProfilViewController.h"
#import "TopBar.h"
#import "AudioStreamManager.h"
#import "ProfilTableViewCell.h"
#import "YasoundDataProvider.h"
#import "YasoundDataCache.h"
#import "Theme.h"
#import "RootViewController.h"
#import "YasoundSessionManager.h"


#define SECTIONS_COUNT 4
#define SECTION_PROFIL 0
#define SECTION_MYRADIOS 1
#define SECTION_FAVORITES 2
#define SECTION_FRIENDS 3

@interface ProfilViewController ()

@end

@implementation ProfilViewController

@synthesize tableview;
@synthesize cellProfil;

@synthesize user;
@synthesize userId;
@synthesize radios;
@synthesize favorites;
@synthesize friends;

@synthesize userImage;
@synthesize name;
@synthesize profil;
@synthesize hd;

@synthesize buttonGray;
@synthesize buttonBlue;
@synthesize buttonGrayLabel;
@synthesize buttonBlueLabel;
@synthesize followed;

@synthesize tabBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forUser:(User*)user
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.user = user;
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withUserId:(NSNumber*)userId
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.userId = userId;
    }
    return self;
}








- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.user)
    {
        [self userReceived:self.user info:nil];
        return;
    }
    
    [[YasoundDataProvider main] userWithId:self.userId target:self action:@selector(userReceived:info:)];
}


- (void)userReceived:(User*)user info:(NSDictionary*)info
{
    DLog(@"userReceived from id '%@' : %p", self.userId, user);
    DLog(@"info : %@", info);
    self.user = user;
    
    if (self.user == nil)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error.generic.title", nil) message:NSLocalizedString(@"Error.generic.message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Navigation.ok", nil) otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }

    [self.tabBar setTabSelected:TabIndexProfil];
    
    self.name.text = self.user.name;
    NSURL* url = [[YasoundDataProvider main] urlForPicture:self.user.picture];
    [self.userImage setUrl:url];
    
    self.profil.text = [self.user formatedProfil];
    
    self.buttonGrayLabel.text = NSLocalizedString(@"Profil.follow", nil);
    self.buttonBlueLabel.text = NSLocalizedString(@"Profil.message", nil);

    // not registered
    if (![YasoundSessionManager main].registered)
    {
        [self enableFollow:NO];
        [self enableSendMessage:NO];    
    }
    // registered, and it's me
    else if ([self.user.id isEqualToNumber:[YasoundDataProvider main].user.id])
    {
        [self enableFollow:NO];
        [self enableSendMessage:NO];
        [[YasoundDataProvider main] friendsForUser:self.user withTarget:self action:@selector(friendsReceived:success:)];
    }
    // someone else
    else
    {
        [self enableFollow:NO];
        [[YasoundDataProvider main] friendsForUser:self.user withTarget:self action:@selector(friendsReceived:success:)];
        
        // is he one of my friends? (<=> I need to know to enable and set the follow/unfollow button properly)
        [[YasoundDataCache main] requestFriendsWithTarget:self action:@selector(myFriendsReceived:success:)];

    }
    


    [[YasoundDataProvider main] radiosForUser:self.user withTarget:self action:@selector(radiosReceived:success:)];
    [[YasoundDataProvider main] favoriteRadiosForUser:self.user withTarget:self action:@selector(favoritesRadioReceived:withInfo:)];
}


- (void)enableFollow:(BOOL)enable
{
    [self.buttonGray setEnabled:enable];
    CGFloat alpha = 1;
    if (!enable)
        alpha = 0.5;
    self.buttonGray.alpha = alpha;
    self.buttonGrayLabel.alpha = alpha;
}

- (void)enableSendMessage:(BOOL)enable
{
    [self.buttonBlue setEnabled:enable];
    CGFloat alpha = 1;
    if (!enable)
        alpha = 0.5;
    self.buttonBlue.alpha = alpha;
    self.buttonBlueLabel.alpha = alpha;
}

- (void)setFollowButtonToFollow
{
    self.buttonGrayLabel.text = NSLocalizedString(@"Profil.follow", nil);
}

- (void)setFollowButtonToUnfollow
{
    self.buttonGrayLabel.text = NSLocalizedString(@"Profil.unfollow", nil);
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







- (void)radiosReceived:(ASIHTTPRequest*)req success:(BOOL)success
{
    if (!success)
    {
        DLog(@"ProfilViewController::radiosReceived failed");
        return;
    }
    
    Container* container = [req responseObjectsWithClass:[Radio class]];
    self.radios = container.objects;
    
    if (self.radios == nil)
    {
        DLog(@"ProfilViewController::radiosReceived error : radios is nil!");
        assert(0);
    }
    
    [self.tableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:SECTION_MYRADIOS]] withRowAnimation:NO];
}


- (void)favoritesRadioReceived:(NSArray*)radios withInfo:(NSDictionary*)info
{
    self.favorites = radios;
    [self.tableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:SECTION_FAVORITES]] withRowAnimation:NO];
}



- (void)myFriendsReceived:(NSArray*)myFriends success:(BOOL)success
{
    DLog(@"%d friends", myFriends.count);
    
    for (User* user in myFriends)
    {
        DLog(@"my friend : %@", user.username);
        
        if ([user.id isEqualToNumber:self.user.id])
        {
            // it's one of my friend.
            // follow button becomes unfollow
            self.followed = YES;
            [self enableFollow:YES];
            [self setFollowButtonToUnfollow];
            return;
        }
    }
    
    // follow
    self.followed = NO;
    [self enableFollow:YES];
    [self setFollowButtonToFollow];
}

- (void)friendsReceived:(ASIHTTPRequest*)req success:(BOOL)success
{
    Container* container = [req responseObjectsWithClass:[User class]];
    self.friends = container.objects;
    [self.tableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:SECTION_FRIENDS]] withRowAnimation:NO];
}









#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTIONS_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_PROFIL)
        return 0;
    
    return 33;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_PROFIL)
        return nil;
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Profil.section" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImageView* view = [sheet makeImage];
    
    sheet = [[Theme theme] stylesheetForKey:@"Profil.sectionTitle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [sheet makeLabel];
    [view addSubview:label];


    if (section == SECTION_MYRADIOS)
        label.text = NSLocalizedString(@"Profil.section.myRadios", nil);
    else if (section == SECTION_FAVORITES)
        label.text = NSLocalizedString(@"Profil.section.favorites", nil);
    else if (section == SECTION_FRIENDS)
        label.text = NSLocalizedString(@"Profil.section.friends", nil);

    return view;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_PROFIL)
        return;

    UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profilRowBkg.png"]];
    cell.backgroundView = view;
    [view release];
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_PROFIL)
        return 91.f;
    return 104.f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_PROFIL)
        return self.cellProfil;
    
    static NSString* cellIdentifier = @"ProfilTableViewCell";
    
    NSArray* items = nil;
    
    if (indexPath.section == SECTION_MYRADIOS)
        items = self.radios;
    else if (indexPath.section == SECTION_FAVORITES)
        items = self.favorites;
    else if (indexPath.section == SECTION_FRIENDS)
        items = self.friends;
    
    
    ProfilTableViewCell* cell = (ProfilTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {    
        cell = [[ProfilTableViewCell alloc] initWithFrame:CGRectMake(0,0, 320, 104) reuseIdentifier:cellIdentifier items:items target:self action:@selector(onItemClicked:)];
    }
    else
    {
        [cell updateWithItems:items];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)onItemClicked:(id)item
{
    if ([item isKindOfClass:[Radio class]])
    {
        Radio* radio = item;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:radio];
        return;
    }

    if ([item isKindOfClass:[User class]])
    {
        User* user = item;
        //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_PROFIL object:user];
        return;
    }
}

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









- (IBAction)onButtonGrayClicked:(id)sender
{
    self.buttonGray.enabled = NO;
    
    if (self.followed)
    {
        self.followed = NO;
        [[YasoundDataProvider main] unfollowUser:self.user target:self action:@selector(onFollowAcknowledge:success:)];
        [self setFollowButtonToFollow];
    }
    else
    {
        self.followed = YES;
        [[YasoundDataProvider main] followUser:self.user target:self action:@selector(onFollowAcknowledge:success:)];
        [self setFollowButtonToUnfollow];
    }
    
}


- (void)onFollowAcknowledge:(ASIHTTPRequest*)req success:(BOOL)success
{
    DLog(@"onFollowAcknowledge %d", success);
    
    // rollback
    if (!success)
    {
        if (self.followed)
        {
            self.followed = NO;
            [self setFollowButtonToFollow];
        }
        else
        {
            self.followed = YES;
            [self setFollowButtonToUnfollow];
        }
    }
    
    [[YasoundDataCache main] clearFriends];
    
    // refresh
    [[YasoundDataCache main] requestFriendsWithTarget:self action:@selector(myFriendsReceived:success:)];
    
        
}


- (IBAction)onButtonBlueClicked:(id)sender
{

}






#pragma mark - TopBarDelegate

//- (BOOL)topBarItemClicked:(TopBarItemId)itemId
//{
//}




#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}





@end
