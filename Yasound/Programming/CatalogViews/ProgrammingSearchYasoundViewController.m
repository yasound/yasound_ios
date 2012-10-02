//
//  ProgrammingSearchYasoundViewController.m
//  Yasound
//
//  Created by mat on 18/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProgrammingSearchYasoundViewController.h"
#import "YasoundDataProvider.h"
#import "YasoundSong.h"
#import "ActionAddServerSongCell.h"

@interface ProgrammingSearchYasoundViewController ()

@end

@implementation ProgrammingSearchYasoundViewController


#define REFRESH_INDICATOR_HEIGHT 62.f


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andRadio:(Radio*)r
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.radio = r;
        _searching = NO;
        _searchResults = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"commonGradient.png"]];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"commonGradient.png"]];
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor clearColor];
    
//    CGRect frame = self.view.frame;
//    frame = CGRectMake(0, frame.size.height - REFRESH_INDICATOR_HEIGHT, frame.size.width, REFRESH_INDICATOR_HEIGHT);
//    self.refreshIndicator = [[RefreshIndicator alloc] initWithFrame:frame];
//    self.refreshIndicator.backgroundColor = [UIColor redColor];
//    [self.searchDisplayController.searchResultsTableView.superview addSubview:self.refreshIndicator];
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView != self.searchDisplayController.searchResultsTableView)
        return 0;
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView != self.searchDisplayController.searchResultsTableView)
        return 0;
    
    if (section > 0)
        return 0;
    
    if (_searchResults == nil)
        return 0;
    
    return _searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.searchDisplayController.searchResultsTableView)
        return nil;
    
    if (indexPath.section > 0)
        return nil;
    
    if (_searchResults == nil)
        return nil;
    
    if (indexPath.row >= _searchResults.count)
        return nil;
    
    YasoundSong* song = [_searchResults objectAtIndex:indexPath.row];
    //DLog(@"%d - song   %@, %@, %@", indexPath.row, song.artist_name, song.album_name, song.name);
    
    static NSString* CellIdentifier = @"SearchServerSongCell";
    
    ActionAddServerSongCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[ActionAddServerSongCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier song:song forRadio:self.radio];
    }
    else
    {
        [cell update:song];
    }
    return cell;
}

#pragma mark - UISearchDisplayDelegate

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    if (controller != self.searchDisplayController)
        return;
    
    DLog(@"will begin search");
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (searchBar != self.searchDisplayController.searchBar)
        return;
    
    self.searchText = searchBar.text;
    DLog(@"search text: %@", self.searchText);
    
    if (_searchResults)
    {
        [_searchResults release];
        _searchResults = nil;
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    
    _searching = YES;
    self.showRefreshIndicator = YES;
    
//    CGRect frame = self.searchDisplayController.searchResultsTableView.frame;
//    frame = CGRectMake(0, frame.size.height + self.searchDisplayController.searchBar.frame.size.height - REFRESH_INDICATOR_HEIGHT, frame.size.width, REFRESH_INDICATOR_HEIGHT);
//    self.refreshIndicator = [[RefreshIndicator alloc] initWithFrame:frame];
//    self.refreshIndicator.backgroundColor = [UIColor redColor];
////    [self.searchDisplayController.searchResultsTableView.superview addSubview:self.refreshIndicator];
//    [self.searchDisplayController.searchContentsController.view addSubview:self.refreshIndicator];
//    [self.searchDisplayController.searchContentsController.view sendSubviewToBack:self.refreshIndicator];
    
    _searchOffset = 0;
    [[YasoundDataProvider main] searchSong:self.searchText count:25 offset:_searchOffset target:self action:@selector(receivedSongs:info:)];
}

- (void)receivedSongs:(NSArray*)songs info:(NSDictionary*)info
{
    if (!songs)
        return;
    
    if (_searchResults)
    {
        [_searchResults release];
        _searchResults = nil;
    }
    _searchResults = songs;
    [self.searchDisplayController.searchResultsTableView reloadData];
    
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"commonGradient.png"]];
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor clearColor];
    
    CGRect frame = self.searchDisplayController.searchResultsTableView.frame;
    frame = CGRectMake(0, frame.size.height + self.searchDisplayController.searchBar.frame.size.height - REFRESH_INDICATOR_HEIGHT, frame.size.width, REFRESH_INDICATOR_HEIGHT);
    self.refreshIndicator = [[RefreshIndicator alloc] initWithFrame:frame];
    self.refreshIndicator.backgroundColor = [UIColor redColor];
    //    [self.searchDisplayController.searchResultsTableView.superview addSubview:self.refreshIndicator];
    [self.view addSubview:self.refreshIndicator];
    [self.view sendSubviewToBack:self.refreshIndicator];
//    [self.searchDisplayController.searchContentsController.view sendSubviewToBack:self.refreshIndicator];
    
}

- (BOOL)onBackClicked
{
    return YES;
}








#pragma mark - UIScrollViewDelegate



//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    
//    [super scrollViewDidScroll:scrollView];
//    
//}
//
//
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    
//    [super scrollViewWillBeginDragging:scrollView];
//    
//}
//


//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    
//    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
//}


- (BOOL) refreshIndicatorRequest {
    
    [super refreshIndicatorRequest];
    
    _searchOffset += 25;
    [[YasoundDataProvider main] searchSong:self.searchText count:25 offset:_searchOffset target:self action:@selector(receivedSongs:info:)];
}





@end
