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

@interface MyRadiosViewController ()

@end

@implementation MyRadiosViewController

@synthesize radios;
@synthesize tableview;
@synthesize tabBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
    }
    return self;
}

- (void)radiosReceived:(Radio*)radio info:(NSDictionary*)info
{
    self.radios = [NSArray arrayWithObject:radio];
    [self.tableview reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tabBar setTabSelected:TabIndexMyRadios];
    
    [[YasoundDataProvider main] userRadioWithTarget:self action:@selector(radiosReceived:info:)];
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
    
    MyRadiosTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[MyRadiosTableViewCell reuseIdentifier]];
    if (cell == nil) 
    {
        cell = [[MyRadiosTableViewCell alloc] initWithOwner:self target:self radio:radio];
    }
    else
    {
        [cell updateWithRadio:radio];
    }
    
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
