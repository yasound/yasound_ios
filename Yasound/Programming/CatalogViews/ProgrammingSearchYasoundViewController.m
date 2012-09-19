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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andRadio:(Radio*)r
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.radio = r;
        _searchResults = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"commonGradient.png"]];
    
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"commonGradient.png"]];
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
    DLog(@"%d - song   %@, %@, %@", indexPath.row, song.artist_name, song.album_name, song.name);
    
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
    
    NSString* searchText = searchBar.text;
    DLog(@"search text: %@", searchText);
    
    if (_searchResults)
    {
        [_searchResults release];
        _searchResults = nil;
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    [[YasoundDataProvider main] searchSong:searchText count:25 offset:0 target:self action:@selector(receivedSongs:info:)];
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
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"commonGradient.png"]];
}

- (BOOL)onBackClicked
{
    return YES;
}

@end
