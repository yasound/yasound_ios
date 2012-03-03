//
//  SongAddViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongAddViewController.h"
#import "Song.h"
#import "SongUploader.h"
#import "SongUploadManager.h"
#import "TimeProfile.h"
#import "ActivityAlertView.h"
#import "SongUploadViewController.h"
#import "SongCatalog.h"
#import "BundleFileManager.h"
#import "Theme.h"

#define BORDER 8

@implementation SongAddViewController



#define SEGMENT_INDEX_ALPHA 0
#define SEGMENT_INDEX_ARTIST 1
#define SEGMENT_INDEX_SERVER 2




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withMatchedSongs:(NSDictionary*)matchedSongs
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        
    }
    return self;
}


- (void)dealloc
{
    [SongCatalog releaseAvailableCatalog];
    [super dealloc];
}





- (void)viewDidLoad
{
    [super viewDidLoad];

    _titleLabel.text = NSLocalizedString(@"SongAddView_title", nil);
    _subtitleLabel.text = NSLocalizedString(@"SongAddView_subtitle", nil);
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
    
    [_segment setTitle:NSLocalizedString(@"SongAddView_segment_titles", nil) forSegmentAtIndex:0];  
    [_segment setTitle:NSLocalizedString(@"SongAddView_segment_artists", nil) forSegmentAtIndex:1];  
    [_segment insertSegmentWithTitle:NSLocalizedString(@"SongAddView_segment_server", nil) atIndex:2 animated:NO];
    
    
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    
    
    [ActivityAlertView showWithTitle:NSLocalizedString(@"SongAddView_alert", nil)];        
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(afterBreath:) userInfo:nil repeats:NO];
}

- (void)afterBreath:(NSTimer*)timer
{
    // PROFILE
    [[TimeProfile main] begin];
    
    [[SongCatalog availableCatalog] buildAvailableComparingToSource:[SongCatalog synchronizedCatalog].matchedSongs];
    
    
    // PROFILE
    [[TimeProfile main] end];
    // PROFILE
    [[TimeProfile main] logInterval:@"Local Media Songs parsing"];

    NSInteger count = [SongCatalog availableCatalog].nbSongs;
    
    NSLog(@"SongAddViewController : %d songs added to the local array", count);
    
    NSString* subtitle = nil;
    if (count == 0)
        subtitle = NSLocalizedString(@"SongAddView_subtitled_count_0", nil);
    else if (count == 1)
        subtitle = NSLocalizedString(@"SongAddView_subtitled_count_1", nil);
    else if (count > 1)
        subtitle = NSLocalizedString(@"SongAddView_subtitled_count_n", nil);
    
    subtitle = [subtitle stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", count]];
    
    _subtitleLabel.text = subtitle;
    

    
    [ActivityAlertView close];
    
    
    
    if (count == 0)
    {
        [_tableView removeFromSuperview];
        NSString* str = NSLocalizedString(@"PlaylistsView_empty_message", nil);
        _itunesConnectLabel.text = str;
        [self.view addSubview:_itunesConnectView];
        
        // IB, sometimes, is, huh.....
        [_itunesConnectView addSubview:_itunesConnectLabel];
        return;
        
    }
    
    [_tableView reloadData];

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


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
//{
//    if (tableView == _settingsTableView)
//        return [self titleInSettingsTableViewForHeaderInSection:section];
//    
//    return nil;
//}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [SongCatalog availableCatalog].indexMap.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSInteger nbRows = [self getNbRowsForTable:tableView inSection:section];
    if (nbRows == 0)
        return 0;
    
    return 22;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSInteger nbRows = [self getNbRowsForTable:tableView inSection:section];
    
    if (nbRows == 0)
        return nil;
    
    NSString* title = [[SongCatalog availableCatalog].indexMap objectAtIndex:section];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MenuSection" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    
    UIImageView* view = [[UIImageView alloc] initWithImage:[sheet image]];
    view.frame = CGRectMake(0, 0, tableView.bounds.size.width, 44);
    
    sheet = [[Theme theme] stylesheetForKey:@"MenuSectionTitle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = title;
    [view addSubview:label];
    
    return view;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [self getNbRowsForTable:tableView inSection:section];
}


- (NSInteger)getNbRowsForTable:(UITableView*)tableView inSection:(NSInteger)section
{
    NSString* charIndex = [[SongCatalog availableCatalog].indexMap objectAtIndex:section];
    
    if (_segment.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
    {
        NSArray* letterRepo = [[SongCatalog availableCatalog].alphabeticRepo objectForKey:charIndex];
        assert(letterRepo != nil);
        return letterRepo.count;
    }
    else
    {
        NSArray* artistsForSection = [[SongCatalog availableCatalog].alphaArtistsOrder objectForKey:charIndex];
        NSInteger count = artistsForSection.count;
        return count;
    }
    
}



//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{    
//    return 44;
//}


//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 22;
//}





- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
    return [SongCatalog availableCatalog].indexMap;
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index 
{
    return index;
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
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    NSString* charIndex = [[SongCatalog availableCatalog].indexMap objectAtIndex:indexPath.section];
    
    if (_segment.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
    {
        NSArray* letterRepo = [[SongCatalog availableCatalog].alphabeticRepo objectForKey:charIndex];
        Song* song = [letterRepo objectAtIndex:indexPath.row];
        
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1];
        
        cell.textLabel.text = song.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", song.album, song.artist];
        
    }
    else
    {
        NSArray* artistsForSection = [[SongCatalog availableCatalog].alphaArtistsOrder objectForKey:charIndex];
        
        NSString* artist = [artistsForSection objectAtIndex:indexPath.row];
        
        NSDictionary* artistsRepo = [[SongCatalog availableCatalog].alphaArtistsRepo objectForKey:charIndex];
        NSDictionary* artistRepo = [artistsRepo objectForKey:artist];
        
        NSInteger nbAlbums = artistRepo.count;
        
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.text = artist;
        
        if (nbAlbums == 1)
            cell.detailTextLabel.text = NSLocalizedString(@"ProgramminView_nb_albums_1", nil);
        else
            cell.detailTextLabel.text = NSLocalizedString(@"ProgramminView_nb_albums_n", nil);
        
        cell.detailTextLabel.text = [cell.detailTextLabel.text stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", nbAlbums]];
    }
    
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    
    
    if (_segment.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
    {
        NSArray* letterRepo = [[SongCatalog availableCatalog].alphabeticRepo objectForKey:[[SongCatalog availableCatalog].indexMap objectAtIndex:indexPath.section]];
        Song* song = [letterRepo objectAtIndex:indexPath.row];
        
        BOOL can = [[SongUploader main] canUploadSong:song];
        if (!can)
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SongAddView_cant_add_title", nil) message:NSLocalizedString(@"SongAddView_cant_add_message", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            [av release];  
            return;
        }
        
        // add an upload job to the queue
        [[SongUploadManager main] addAndUploadSong:song];
        
        // and flag the current song as "uploading song"
        song.uploading = YES;
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell setNeedsLayout];
        
        [ActivityAlertView showWithTitle:NSLocalizedString(@"SongAddView_added", nil) closeAfterTimeInterval:1];
    }
    else
    {
        [[SongCatalog availableCatalog] selectArtistInSection:indexPath.section atRow:indexPath.row];
        
//        ProgrammingArtistViewController* view = [[ProgrammingArtistViewController alloc] initWithNibName:@"ProgrammingArtistViewController" bundle:nil];
//        [self.navigationController pushViewController:view animated:YES];
//        [view release];
    }
    
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

- (IBAction)onSegmentClicked:(id)sender
{
    
}



@end

































