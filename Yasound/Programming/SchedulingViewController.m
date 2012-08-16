//
//  SchedulingViewController.m
//  Yasound
//
//  Created by neywen on 11/08/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SchedulingViewController.h"
#import "YasoundDataProvider.h"
#import "Theme.h"
#import <QuartzCore/QuartzCore.h>
#import "ShowViewController.h"

@interface SchedulingViewController ()

@end

@implementation SchedulingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forRadio:(Radio*)radio
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.radio = radio;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.topBar showAddItem];
    
    [[YasoundDataProvider main] showsForRadio:self.radio withTarget:self action:@selector(showsReceived:success:)];
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




- (void)showsReceived:(ASIHTTPRequest*)req success:(BOOL)success
{
    if (!success)
    {
        DLog(@"SchedulingViewController::showsReceived failed");
        return;
    }
    
    Container* container = [req responseObjectsWithClass:[Radio class]];
    self.shows = container.objects;
    [self.tableview reloadData];    
}




#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.shows.count;
}


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//	if (section == SECTION_DEFAULT)
//        return @"Default";
//    
//    return @"Shows";
//        
//}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46.f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.cell" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImageView* view = [sheet makeImage];
    cell.backgroundView = view;
    [view autorelease];
}


 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifierShow = @"cellShow";
    
    UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifierShow];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifierShow];
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.textColor = [UIColor colorWithRed:166.f/255.f green:177.f/255.f blue:185.f/255.f alpha:1];
        cell.textLabel.layer.shadowColor = [UIColor blackColor];
        cell.textLabel.layer.shadowOffset = CGSizeMake(0, -1);
        cell.textLabel.layer.shadowRadius = 0.5;
        cell.textLabel.layer.shadowOpacity = 0.75;
        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.disclosureIndicator" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIImageView* di = [sheet makeImage];
        [cell addSubview:di];
        [di release];
    }
    
    return cell;
    
    
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

- (void)topBarItemClicked:(TopBarItemId)itemId
{
    if (itemId == TopBarItemAdd)
    {
        ShowViewController* view = [[ShowViewController alloc] initWithNibName:@"ShowViewController" bundle:nil];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
}




@end
