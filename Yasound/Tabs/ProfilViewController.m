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


#define SECTIONS_COUNT 4
#define SECTION_PROFIL 0
#define SECTION_MYRADIOS 1
#define SECTION_FAVORITES 2
#define SECTION_FRIENDS 3

@interface ProfilViewController ()

@end

@implementation ProfilViewController

@synthesize tabBar;

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
    [self.tabBar setTabSelected:TabIndexProfil];
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
    return SECTIONS_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
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
    return nil;
    
    ProfilTableViewCell* cell = (ProfilTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {    
        cell = [[ProfilTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier items:items target:self action:@selector(onItemClicked:)];
    }
    else
    {
        [cell updateWithItems:items];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
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
