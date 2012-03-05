//
//  ProgrammingArtistViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProgrammingArtistViewController.h"
#import "ActivityAlertView.h"
#import "Radio.h"
#import "YasoundDataProvider.h"
#import "SongInfoViewController.h"
#import "SongUploadViewController.h"
#import "SongAddViewController.h"
#import "TimeProfile.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "SongCatalog.h"
#import "ProgrammingAlbumViewController.h"
#import "RootViewController.h"



@implementation ProgrammingArtistViewController



@synthesize catalog;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil usingCatalog:(SongCatalog*)catalog
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.catalog = catalog;
    }
    return self;
}


- (void)dealloc
{
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}





- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongAdded:) name:NOTIF_PROGAMMING_SONG_ADDED object:nil];
    

    if (self.catalog == [SongCatalog synchronizedCatalog])
        _titleLabel.text = NSLocalizedString(@"ProgrammingView_title", nil);
    else if (self.catalog == [SongCatalog availableCatalog])
        _titleLabel.text = NSLocalizedString(@"SongAddView_title", nil);

    _subtitleLabel.text = self.catalog.selectedArtist;
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
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














#pragma mark - TableView Source and Delegate




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSInteger count = self.catalog.selectedArtistRepo.count;
    return count;
}




- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellPlainRow.png"]];
    cell.backgroundView = view;
    [view release];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];

    NSString* charIndex = [self.catalog.indexMap objectAtIndex:indexPath.section];
    
    NSArray* albums = [self.catalog.selectedArtistRepo allKeys];
    NSArray* albumRepos = [self.catalog.selectedArtistRepo allValues];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [albums objectAtIndex:indexPath.row];
    
    
    NSArray* songs = [albumRepos objectAtIndex:indexPath.row];
    NSInteger nbSongs = songs.count;
    
    if (nbSongs == 1)
        cell.detailTextLabel.text = NSLocalizedString(@"ProgramminView_nb_songs_1", nil);
    else
        cell.detailTextLabel.text = NSLocalizedString(@"ProgramminView_nb_songs_n", nil);
    
    cell.detailTextLabel.text = [cell.detailTextLabel.text stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", nbSongs]];    

    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    [self.catalog selectAlbumAtRow:indexPath.row];

    ProgrammingAlbumViewController* view = [[ProgrammingAlbumViewController alloc] initWithNibName:@"ProgrammingAlbumViewController" bundle:nil usingCatalog:self.catalog];
    [self.navigationController pushViewController:view animated:YES];
    [view release];

}
















#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSynchronize:(id)semder
{
    SongUploadViewController* view = [[SongUploadViewController alloc] initWithNibName:@"SongUploadViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}


- (IBAction)onAdd:(id)sender
{
    SongAddViewController* view = [[SongAddViewController alloc] initWithNibName:@"SongAddViewController" bundle:nil withMatchedSongs:[SongCatalog synchronizedCatalog].matchedSongs];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}


- (void)onNotifSongAdded:(NSNotification*)notif
{
    [_tableView reloadData];    
}




@end
