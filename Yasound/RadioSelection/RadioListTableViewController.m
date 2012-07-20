//
//  RadioListTableViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 19/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "RadioListTableViewController.h"
#import "RadioListTableViewCell.h"

@interface RadioListTableViewController ()

@end


@implementation RadioListTableViewController

@synthesize listDelegate;
@synthesize radios;

- (id)initWithStyle:(UITableViewStyle)style radios:(NSArray*)radios
{
    self = [super initWithStyle:style];
    if (self) 
    {
        self.radios = radios;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"radioListRowBkgSize2.png"]];
    }
    return self;
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
    if (self.radios == nil)
        return 0;
    
    return self.radios.count / 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 156.f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"RadioListTableViewCell";
    
    RadioListTableViewCell* cell = (RadioListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSInteger radioIndex = indexPath.row * 2;
    
    Radio* radio1 = [self.radios objectAtIndex:radioIndex];
    Radio* radio2 = nil;
    if (radioIndex+1 < self.radios.count)
        radio2 = [self.radios objectAtIndex:radioIndex+1];
    
    NSArray* radiosForRow = [NSArray arrayWithObjects:radio1, radio2, nil];
    
    if (cell == nil)
    {    
        cell = [[RadioListTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier radios:radiosForRow];
    }
    else
    {
        [cell updateWithRadios:radiosForRow];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // call delegate with selected radio
    Radio* radio = [self.radios objectAtIndex:indexPath.row];
    [self.listDelegate radioListDidSelect:radio];
}

@end
