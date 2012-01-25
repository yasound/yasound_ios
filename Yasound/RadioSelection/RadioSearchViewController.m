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


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabItem:(UITabBarSystemItem)tabItem
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) 
  {
    UITabBarItem* theItem = [[UITabBarItem alloc] initWithTabBarSystemItem:tabItem tag:0];
    self.tabBarItem = theItem;
    [theItem release];      
    
  }
  
  return self;
    
}


- (void)dealloc
{
    if (_radios != nil)
        [_radios release];
    [super dealloc];
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
    if (_radios == nil)
        return 0;
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (_radios == nil)
        return 0;
    
    NSLog(@"RADIO COUNT %d", _radios.count);
    
    return _radios.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 55;
}





- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
  static NSString *cellIdentifier = @"RadioSelectionTableViewCell";
  
    NSInteger rowIndex = indexPath.row;

    Radio* radio = [_radios objectAtIndex:rowIndex];
    RadioSelectionTableViewCell* cell = [[RadioSelectionTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier rowIndex:rowIndex radio:radio];  
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RadioSelectionTableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
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
    
    [[YasoundDataProvider main] searchRadios:searchBar.text withGenre:nil withTarget:self action:@selector(receiveRadios:withInfo:)];
}




- (void)receiveRadios:(NSArray*)radios withInfo:(NSDictionary*)info
{
    NSError* error = [info valueForKey:@"error"];
    if (error)
    {
        NSLog(@"can't get radios: %@", error.domain);
        return;
    }
    
    if (_radios != nil)
        [_radios release];
    
    _radios = radios;
    [_radios retain];
    [self.searchDisplayController.searchResultsTableView reloadData];
}


#pragma mark - IBActions

- (IBAction)menuBarItemClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

 


@end
