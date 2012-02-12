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
#import "AudioStreamManager.h"



@implementation RadioSearchViewController


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabItem:(UITabBarSystemItem)tabItem
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) 
  {
//    UITabBarItem* theItem = [[UITabBarItem alloc] initWithTabBarSystemItem:tabItem tag:0];
//    self.tabBarItem = theItem;
//    [theItem release];   
      

    
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

//    _toolbarTitle.text = NSLocalizedString(@"FriendsView_title", nil);
    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);
    
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    
    
    _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _searchController.searchResultsTableView.backgroundColor = _tableView.backgroundColor;
    _searchController.searchResultsTableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;

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







- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *cellIdentifier = @"RadioSelectionTableViewCell";
    
    if (!_radios)
        return nil;
    
    RadioSelectionTableViewCell* cell = (RadioSelectionTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSInteger rowIndex = indexPath.row;
    Radio* radio = [_radios objectAtIndex:rowIndex];
    
    if (cell == nil)
    {    
        cell = [[RadioSelectionTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier rowIndex:rowIndex radio:radio];
    }
    else
        [cell updateWithRadio:radio rowIndex:rowIndex];
    
    
    
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
    
    [[YasoundDataProvider main] searchRadios:searchBar.text withTarget:self action:@selector(receiveRadios:withInfo:)];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"searchBarSearchButtonClicked %@", searchBar.text);
    
    [[YasoundDataProvider main] searchRadios:searchBar.text withTarget:self action:@selector(receiveRadios:withInfo:)];
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

- (IBAction)nowPlayingClicked:(id)sender
{
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:[AudioStreamManager main].currentRadio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}


- (IBAction)menuBarItemClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

 


@end
