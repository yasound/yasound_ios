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

@interface MyRadiosViewController ()

@end

@implementation MyRadiosViewController

@synthesize radios;
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





- (void)onGetRadio:(Radio*)radio info:(NSDictionary*)info
{
    //    assert(radio);
    
    // account just being create, go to configuration screen
    [[UserSettings main] setBool:YES forKey:USKEYskipRadioCreation];
    
    CreateMyRadio* view = [[CreateMyRadio alloc] initWithNibName:@"CreateMyRadio" bundle:nil wizard:YES radio:radio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];    
}






#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 156.f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"RadioListTableViewCell";
    return nil;
    
//    RadioListTableViewCell* cell = (RadioListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    
//    NSInteger radioIndex = indexPath.row * 2;
//    
//    Radio* radio1 = [self.radios objectAtIndex:radioIndex];
//    Radio* radio2 = nil;
//    if (radioIndex+1 < self.radios.count)
//        radio2 = [self.radios objectAtIndex:radioIndex+1];
//    
//    NSArray* radiosForRow = [NSArray arrayWithObjects:radio1, radio2, nil];
//    
//    if (cell == nil)
//    {    
//        cell = [[RadioListTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier radios:radiosForRow target:self action:@selector(onRadioClicked:)];
//    }
//    else
//    {
//        [cell updateWithRadios:radiosForRow target:self action:@selector(onRadioClicked:)];
//    }
//    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    
//    return cell;
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
