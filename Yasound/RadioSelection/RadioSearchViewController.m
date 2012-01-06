//
//  RadioSearchViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 28/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioSearchViewController.h"
#import "RadioSelectionTableViewCell.h"
#import "RadioViewController.h"


@implementation RadioSearchViewController


//LBDEBUG
static NSArray* gFakeSearchUsers = nil;


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabItem:(UITabBarSystemItem)tabItem
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) 
  {
    UITabBarItem* theItem = [[UITabBarItem alloc] initWithTabBarSystemItem:tabItem tag:0];
    self.tabBarItem = theItem;
    [theItem release];      
    
    // LBDEBUG static init
    if (gFakeSearchUsers == nil)
    {
      NSDictionary* resources = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Resources"];
      gFakeSearchUsers = [resources objectForKey:@"fakeUsers"];
    }
    ///////////////
    
    
  }
  
  return self;
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
  [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}












#pragma mark - TableView Source and Delegate




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
  // Number of rows is the number of time zones in the region for the specified section.
  return 24;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 55;
}





- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
  static NSString *cellIdentifier = @"RadioSelectionTableViewCell";
  
    NSInteger rowIndex = indexPath.row;

    //LBDEBUG ICI
    Radio* radio = nil;
//    Radio* radio = [_radios objectAtIndex:rowIndex];
    
    RadioSelectionTableViewCell* cell = [[RadioSelectionTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier rowIndex:rowIndex radio:radio];  
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RadioSelectionTableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
    
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:cell.radio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];  
}







#pragma mark - UISearchBarDelegate


//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//  NSLog(@"textDidChange %@", searchText);
//}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
  NSLog(@"searchBarTextDidEndEditing %@", searchBar.text);
 
}



@end
