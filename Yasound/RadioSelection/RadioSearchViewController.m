//
//  RadioSearchViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 28/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioSearchViewController.h"
#import "RadioSearchTableViewCell.h"
//#import "RadioViewController.h"
#import "AudioStreamManager.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "RootViewController.h"
#import "ProfilCellRadio.h"

#define ROW_HEIGHT 66.0

typedef enum 
{
  eSearchByRadioAttributes = 0,
  eSearchByRadioCreator = 1,
  eSearchByRadioSong = 2,
  eSearchNone = 3
} SearchResultCategory;


@implementation RadioSearchViewController


@synthesize delayTokens;
@synthesize delay;


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) 
  {
//    UITabBarItem* theItem = [[UITabBarItem alloc] initWithTabBarSystemItem:tabItem tag:0];
//    self.tabBarItem = theItem;
//    [theItem release];
      
      self.delayTokens = 2;
      self.delay = 0.15;

    
  }
  
  return self;
    
}


- (void)dealloc
{
    if (_radios != nil)
        [_radios release];
//  [_nowPlayingButton release];
  [_searchController release];
//  [_backgroundColor release];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSearchRadioClicked:) name:NOTIF_SEARCH_RADIO_SELECTED object:nil];
  
  _radios = nil;
  _radiosByCreator = nil;
  _radiosBySong = nil;
  
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"radioListRowBkgSize2.png"]];
//  _backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
//  [_backgroundColor retain];
//  
//  self.view.backgroundColor = _backgroundColor;

//    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);
    
  _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  _searchController.searchResultsTableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
//  _searchController.searchResultsTableView.backgroundColor = _backgroundColor;
  _searchController.searchResultsTableView.rowHeight = ROW_HEIGHT;

  _searchController.searchBar.placeholder = NSLocalizedString(@"SearchBar_Placeholder", nil);
    
    _searchController.searchResultsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"radioListRowBkgSize2.png"]];
    

    // import previous search, if any
    NSString* searchtext = [[UserSettings main] objectForKey:USKEYradioSearch];
    if ((searchtext != nil) && (searchtext.length > 0))
        [self searchRadios:searchtext];

    
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








- (void)onSearchRadioClicked:(NSNotification*)notif {
    
    Radio* radio = notif.object;
    assert(radio);

    // emitted from the cell unit, now
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:radio userInfo:nil];

    [self.popover dismissPopoverAnimated:YES];
    
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
  
    NSInteger nbRows = radios.count / 3;
    if ((radios.count % 3) != 0)
        nbRows++;
    return nbRows;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 102.f;
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
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.Section.background" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImageView* view = [sheet makeImage];
    
    sheet = [[Theme theme] stylesheetForKey:@"TableView.Section.label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = title;
    [view addSubview:label];
    
  return view;
}









- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString* cellRadioIdentifier = @"RadioSearchTableViewCell";

    NSArray* radios = [self radiosForSection:indexPath.section];
    
    RadioSearchTableViewCell* cell = (RadioSearchTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellRadioIdentifier];
    
    
    
//    for (Radio* radio in _items) {
//        
//        ProfilCellRadio* cell = [[ProfilCellRadio alloc] initWithRadio:radio];
//        cell.frame = CGRectMake(posX, 0, cell.frame.size.width, cell.frame.size.height);
//
//        [self.scrollview addSubview:cell];
//        
//        posX += cell.frame.size.width;
//        posX += 4;
//        
//        // animation to delay the display
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDelay:delay];
//        [UIView setAnimationDuration:0.3];
//        cell.alpha = 1;
//        [UIView commitAnimations];
//        
//        delay += 0.1;
//    }

    
    
    
    NSInteger radioIndex = indexPath.row * 3;
    
    //LBDEBUG
//    NSLog(@"radioIndex %d    count %d", radioIndex, radios.count);
    
    Radio* radio1 = [radios objectAtIndex:radioIndex];
    Radio* radio2 = nil;
    Radio* radio3 = nil;
    if (radioIndex+1 < radios.count)
        radio2 = [radios objectAtIndex:radioIndex+1];
    if (radioIndex+2 < radios.count)
        radio3 = [radios objectAtIndex:radioIndex+2];
    
    NSArray* radiosForRow = [NSArray arrayWithObjects:radio1, radio2, radio3, nil];
    
    if (cell == nil)
    {
//        CGFloat delay = 0;
//        if (self.delayTokens > 0)
//            delay = self.delay;
//        
        cell = [[RadioSearchTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellRadioIdentifier radios:radiosForRow target:self action:@selector(onRadioClicked:)];
//        
//        self.delayTokens--;
//        self.delay += 0.3;
    }
    else
    {
        [cell updateWithRadios:radiosForRow target:self action:@selector(onRadioClicked:)];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;

}


//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //RadioListTableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
//    NSInteger rowIndex = indexPath.row;
//    NSInteger sectionIndex = indexPath.section;
//    
//    NSArray* radios = [self radiosForSection:sectionIndex];
//    if (!radios)
//        return;
//    Radio* radio = [radios objectAtIndex:rowIndex];
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:radio];
//    
////    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:radio];
//}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
- (void)onRadioClicked:(Radio*)radio
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:radio];
}


#pragma mark - UISearchDisplayDelegate


- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    
    [[UserSettings main] setObject:@"" forKey:USKEYradioSearch];
}


- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
  _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  _searchController.searchResultsTableView.indicatorStyle = UIScrollViewIndicatorStyleWhite; 
//  _searchController.searchResultsTableView.backgroundColor = _backgroundColor;
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
    
    [[UserSettings main] setObject:searchText forKey:USKEYradioSearch];
  
    [self.searchDisplayController.searchBar becomeFirstResponder];
    self.searchDisplayController.searchBar.text = searchText;
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


//#pragma mark - IBActions
//
//- (IBAction)nowPlayingClicked:(id)sender
//{
//    RadioViewController* view = [[RadioViewController alloc] initWithRadio:[AudioStreamManager main].currentRadio];
//    [self.navigationController pushViewController:view animated:YES];
//    [view release];
//}
//
//
//- (IBAction)menuBarItemClicked:(id)sender
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}

 


@end
