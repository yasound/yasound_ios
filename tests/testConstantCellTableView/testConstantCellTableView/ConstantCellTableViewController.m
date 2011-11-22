//
//  ConstantCellTableViewController.m
//  testConstantCellTableView
//
//  Created by LOIC BERTHELOT on 22/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ConstantCellTableViewController.h"

@implementation ConstantCellTableViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}












#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 24;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString* CellIdentifier = @"Cell";

//  NSString* cellIdentifier;


  
//  if (indexPath.row == 4)
//    cellIdentifier = [NSString stringWithString:@"NowPlaying"];
//  else if (indexPath.row == 12)
//    cellIdentifier = [NSString stringWithString:@"Played"];
//  else
//    cellIdentifier = CommonCellIdentifier;
  
  if ((indexPath.row == 4) || (indexPath.row == 8) || (indexPath.row == 14) || (indexPath.row == 19))
  {
    NSString* cellIdentifier;
    if (indexPath.row == 4)
      cellIdentifier = @"NowPlayingTableViewCell";
    else 
      cellIdentifier = @"PlayedTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) 
    {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }

    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
    cell = [topLevelObjects objectAtIndex:0];
    return cell;
  }
  else
  {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"yasound %d", indexPath.row];
    return cell;
  }

  return nil;
}









#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}












@end
