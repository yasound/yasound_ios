//
//  MyRadiosViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "MyRadiosViewController.h"
#import "TopBar.h"
#import "RadioViewController.h"
#import "AudioStreamManager.h"
#import "YasoundDataProvider.h"
#import "MyRadiosTableViewCell.h"
#import "RootViewController.h"

@interface MyRadiosViewController ()

@end

@implementation MyRadiosViewController

static NSString* CellIdentifier = @"MyRadiosTableViewCell";

@synthesize cellLoader;
@synthesize radios;
@synthesize tableview;
@synthesize tabBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.cellLoader = [UINib nibWithNibName:CellIdentifier bundle:[NSBundle mainBundle]];
    }
    return self;
}



- (void)dealloc
{
    [self.cellLoader release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tabBar setTabSelected:TabIndexMyRadios];
    [[YasoundDataProvider main] radiosForUser:[YasoundDataProvider main].user withTarget:self action:@selector(radiosReceived:success:)];
}


- (void)radiosReceived:(ASIHTTPRequest*)req success:(BOOL)success
{
    if (!success)
    {
        DLog(@"MyRadiosViewController::radiosReceived failed");
        return;
    }
    
    Container* container = [req responseObjectsWithClass:[UserNotification class]];
    self.radios = container.objects;
    [self.tableview reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableview reloadData];
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
    if (self.radios == nil)
        return 0;
    
    return self.radios.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 167.f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Radio* radio = [self.radios objectAtIndex:indexPath.row];
    
    MyRadiosTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        NSArray *topLevelItems = [self.cellLoader instantiateWithOwner:self options:nil];
        cell = [topLevelItems objectAtIndex:0];
        cell.delegate = self;
    }
        
    [cell updateWithRadio:radio target:self];
    
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










#pragma mark - MyRadiosTableViewCellDelegate

- (void)myRadioRequestedPlay:(Radio*)radio
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_RADIO object:radio];
}

- (void)myRadioRequestedStats:(Radio*)radio
{

}

- (void)myRadioRequestedSettings:(Radio*)radio
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
