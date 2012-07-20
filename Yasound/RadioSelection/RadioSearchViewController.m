//
//  RadioSearchViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 28/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioSearchViewController.h"
#import "RadioListTableViewCell.h"
#import "RadioViewController.h"
#import "AudioStreamManager.h"
#import "BundleFileManager.h"
#import "Theme.h"

#define ROW_HEIGHT 66.0

typedef enum 
{
  eSearchByRadioAttributes = 0,
  eSearchByRadioCreator = 1,
  eSearchByRadioSong = 2,
  eSearchNone = 3
} SearchResultCategory;


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
  [_nowPlayingButton release];
  [_searchController release];
  [_backgroundColor release];
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
  
  _radios = nil;
  _radiosByCreator = nil;
  _radiosBySong = nil;
  
  _backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
  [_backgroundColor retain];
  
  self.view.backgroundColor = _backgroundColor;

    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);
    
  _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  _searchController.searchResultsTableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
  _searchController.searchResultsTableView.backgroundColor = _backgroundColor;
  _searchController.searchResultsTableView.rowHeight = ROW_HEIGHT;

  _searchController.searchBar.placeholder = NSLocalizedString(@"SearchBar_Placeholder", nil);
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
  [_searchController.searchResultsTableView deselectRowAtIndexPath:[_searchController.searchResultsTableView indexPathForSelectedRow] animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidAppear:(BOOL)animated
{
  _viewVisible = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
  _viewVisible = NO;
}










#pragma mark - TableView Source and Delegate


- (SearchResultCategory)categoryForSection:(NSInteger)section
{
  NSInteger radiosSection = 0;
  NSInteger radiosByCreatorSection = 1;
  NSInteger radiosBySongSection = 2;
  if (!_radios)
  {
    radiosSection = -1;
    radiosByCreatorSection--;
    radiosBySongSection--;
  }
  if (!_radiosByCreator)
  {
    radiosByCreatorSection = -1;
    radiosBySongSection--;
  }
  if (!_radiosBySong)
    radiosBySongSection = -1;
  
  if (section == radiosSection)
    return eSearchByRadioAttributes;
  else if (section == radiosByCreatorSection)
    return eSearchByRadioCreator;
  else if (section == radiosBySongSection)
    return eSearchByRadioSong;
  
  return eSearchNone;
}


- (NSArray*)radiosForSection:(NSInteger)section
{
  SearchResultCategory cat = [self categoryForSection:section];
  switch (cat) 
  {
    case eSearchByRadioAttributes:
      return _radios;
      break;
      
    case eSearchByRadioCreator:
      return _radiosByCreator;
      break;
      
    case eSearchByRadioSong:
      return _radiosBySong;
      break;
      
    case eSearchNone:
    default:
      break;
  }
  
  return nil;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  NSInteger nbSections = 0;
  if (_radios)
    nbSections++;
  if (_radiosByCreator)
    nbSections++;
  if (_radiosBySong)
    nbSections++;
  return nbSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
  NSArray* radios = [self radiosForSection:section];
  if (!radios)
    return 0;
  
  NSInteger count = radios.count;
  DLog(@"RADIO COUNT %d", count);
  return count;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  NSString* title = nil;
  
  SearchResultCategory cat = [self categoryForSection:section];
  switch (cat) 
  {
    case eSearchByRadioAttributes:
      title = NSLocalizedString(@"RadioSearch_CategoryRadioAttributes_SectionTitle", nil);
      break;
      
    case eSearchByRadioCreator:
      title = NSLocalizedString(@"RadioSearch_CategoryRadioCreator_SectionTitle", nil);
      break;
      
    case eSearchByRadioSong:
      title = NSLocalizedString(@"RadioSearch_CategoryRadioSong_SectionTitle", nil);
      break;
      
    default:
      break;
  }
  
  BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Menu.MenuSection" retainStylesheet:YES overwriteStylesheet:NO error:nil];
  
  UIImageView* view = [[UIImageView alloc] initWithImage:[sheet image]];
  view.frame = CGRectMake(0, 0, tableView.bounds.size.width, 44);
  
  sheet = [[Theme theme] stylesheetForKey:@"Menu.MenuSectionTitle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
  UILabel* label = [sheet makeLabel];
  label.text = title;
  [view addSubview:label];
  
  return view;
}









- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *cellIdentifier = @"RadioListTableViewCell";
  NSInteger rowIndex = indexPath.row;
  NSInteger sectionIndex = indexPath.section;
    
  NSArray* radios = [self radiosForSection:sectionIndex];
  if (!radios)
    return nil;
    
    RadioListTableViewCell* cell = (RadioListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    Radio* radio = [radios objectAtIndex:rowIndex];
    
    if (cell == nil)
    {    
        cell = [[RadioListTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier rowIndex:rowIndex radio:radio];
    }
    else
        [cell updateWithRadio:radio rowIndex:rowIndex];
  
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RadioListTableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    //LBDEBUG TODO
    
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:nil];
    [self.navigationController pushViewController:view animated:YES];
    [view release];  
}


#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
  _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  _searchController.searchResultsTableView.indicatorStyle = UIScrollViewIndicatorStyleWhite; 
  _searchController.searchResultsTableView.backgroundColor = _backgroundColor;
  _searchController.searchResultsTableView.rowHeight = ROW_HEIGHT;
}




#pragma mark - UISearchBarDelegate

- (void)searchRadios:(NSString*)searchText
{
  if (_radios != nil)
    [_radios release];
  _radios = nil;
  if (_radiosByCreator != nil)
    [_radiosByCreator release];
  _radiosByCreator = nil;
  if (_radiosBySong != nil)
    [_radiosBySong release];
  _radiosBySong = nil;
  
  [self.searchDisplayController.searchResultsTableView reloadData];
  
  [[YasoundDataProvider main] searchRadios:searchText withTarget:self action:@selector(receiveRadios:withInfo:)];
  [[YasoundDataProvider main] searchRadiosByCreator:searchText withTarget:self action:@selector(receiveRadiosSearchedByCreator:withInfo:)];
  [[YasoundDataProvider main] searchRadiosBySong:searchText withTarget:self action:@selector(receiveRadiosSearchBySong:withInfo:)];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  [self searchRadios:searchBar.text];
}





- (void)receiveRadios:(NSArray*)radios withInfo:(NSDictionary*)info
{
  if (!_viewVisible)
    return;
  
    NSError* error = [info valueForKey:@"error"];
    if (error)
    {
        DLog(@"can't get radios: %@", error.domain);
        return;
    }
    
    if (_radios != nil)
    {
        [_radios release];
      _radios = nil;
    }
    
  if (radios.count > 0)
  {
    _radios = radios;
    [_radios retain];
  }
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)receiveRadiosSearchedByCreator:(NSArray*)radios withInfo:(NSDictionary*)info
{
  if (!_viewVisible)
    return;
  
  NSError* error = [info valueForKey:@"error"];
  if (error)
  {
    DLog(@"can't get radios: %@", error.domain);
    return;
  }
  
  if (_radiosByCreator != nil)
  {
    [_radiosByCreator release];
    _radiosByCreator = nil;
  }
  
  if (radios.count > 0)
  {
    _radiosByCreator = radios;
    [_radiosByCreator retain];
  }
  
  [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)receiveRadiosSearchBySong:(NSArray*)radios withInfo:(NSDictionary*)info
{
  if (!_viewVisible)
    return;
  
  NSError* error = [info valueForKey:@"error"];
  if (error)
  {
    DLog(@"can't get radios: %@", error.domain);
    return;
  }
  
  if (_radiosBySong != nil)
  {
    [_radiosBySong release];
    _radiosBySong = nil;
  }
  
  if (radios.count > 0)
  {
    _radiosBySong = radios;
    [_radiosBySong retain];
  }
  
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
