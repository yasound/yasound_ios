//
//  ProfilViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProfilViewController.h"
#import "TopBar.h"
#import "RadioViewController.h"
#import "AudioStreamManager.h"
#import "ProfilTableViewCell.h"
#import "YasoundDataProvider.h"
#import "YasoundDataCache.h"
#import "Theme.h"
#import "RootViewController.h"

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
@synthesize radios;
@synthesize favorites;
@synthesize friends;

@synthesize userImage;
@synthesize name;
@synthesize bio;
@synthesize hd;

@synthesize buttonGrayLabel;
@synthesize buttonBlueLabel;

@synthesize tabBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.user = [YasoundDataProvider main].user;
    }
    return self;
}







- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tabBar setTabSelected:TabIndexProfil];
    
    self.name.text = self.user.name;
    NSURL* url = [[YasoundDataProvider main] urlForPicture:self.user.picture];
    [self.userImage setUrl:url];
    
    self.buttonGrayLabel.text = NSLocalizedString(@"Profil.follow", nil);
    self.buttonBlueLabel.text = NSLocalizedString(@"Profil.message", nil);

    [[YasoundDataProvider main] radiosForUser:self.user withTarget:self action:@selector(radiosReceived:success:)];
    [[YasoundDataProvider main] favoriteRadiosForUser:self.user withTarget:self action:@selector(favoritesRadioReceived:withInfo:)];
    [[YasoundDataCache main] requestFriendsWithTarget:self action:@selector(friendsReceived:info:)];
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



- (void)friendsReceived:(NSArray*)friends info:(NSDictionary*)info
{
    self.friends = friends;
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
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_RADIO object:radio];
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

}


- (IBAction)onButtonBlueClicked:(id)sender
{

}






#pragma mark - TopBarDelegate

- (void)topBarBackItemClicked:(TopBarItemId)itemId
{
    if (itemId == TopBarItemBack)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    else if (itemId == TopBarItemNotif)
    {
        
    }
    
    else if (itemId == TopBarItemNowPlaying)
    {
        RadioViewController* view = [[RadioViewController alloc] initWithRadio:[AudioStreamManager main].currentRadio];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
}

@end
