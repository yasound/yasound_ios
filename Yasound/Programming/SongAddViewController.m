//
//  SongAddViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongAddViewController.h"
#import "Song.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SongUploader.h"
#import "SongUploadManager.h"
#import "TimeProfile.h"
#import "ActivityAlertView.h"
#import "SongUploadViewController.h"


#define PM_FIELD_UNKNOWN @""
#define BORDER 8

@implementation SongAddViewController



#define SEGMENT_INDEX_ALPHA 0
#define SEGMENT_INDEX_ARTIST 1
#define SEGMENT_INDEX_SERVER 2


@synthesize  localSongs;
@synthesize remoteSongs;
@synthesize matchedSongs;

static NSMutableArray* gIndexMap = nil;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withMatchedSongs:(NSDictionary*)matchedSongs
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.matchedSongs = matchedSongs;
        
        self.alphabeticRepo = [[NSMutableDictionary alloc] init];
        self.artistsRepo = [[NSMutableDictionary alloc] init];
        self.artistsIndexSections = [[NSMutableArray alloc] init];
        
        if (gIndexMap == nil)
            [self initIndexMap];
        
        for (NSString* indexKey in gIndexMap)
        {
            NSMutableArray* letterRepo = [[NSMutableArray alloc] init];
            [self.alphabeticRepo setObject:letterRepo forKey:indexKey];
        }
        
    }
    return self;
}


- (void)initIndexMap
{
    gIndexMap = [[NSMutableArray alloc] init];
    [gIndexMap retain];
    [gIndexMap addObject:@"-"];
    [gIndexMap addObject:@"A"];
    [gIndexMap addObject:@"B"];
    [gIndexMap addObject:@"C"];
    [gIndexMap addObject:@"D"];
    [gIndexMap addObject:@"E"];
    [gIndexMap addObject:@"F"];
    [gIndexMap addObject:@"G"];
    [gIndexMap addObject:@"H"];
    [gIndexMap addObject:@"I"];
    [gIndexMap addObject:@"J"];
    [gIndexMap addObject:@"K"];
    [gIndexMap addObject:@"L"];
    [gIndexMap addObject:@"M"];
    [gIndexMap addObject:@"N"];
    [gIndexMap addObject:@"O"];
    [gIndexMap addObject:@"P"];
    [gIndexMap addObject:@"Q"];
    [gIndexMap addObject:@"R"];
    [gIndexMap addObject:@"S"];
    [gIndexMap addObject:@"T"];
    [gIndexMap addObject:@"U"];
    [gIndexMap addObject:@"V"];
    [gIndexMap addObject:@"W"];
    [gIndexMap addObject:@"X"];
    [gIndexMap addObject:@"Y"];
    [gIndexMap addObject:@"Z"];
    [gIndexMap addObject:@"#"];
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
    
    // PROFILE
    [[TimeProfile main] begin];
    
    
    MPMediaQuery* allAlbumsQuery = [MPMediaQuery albumsQuery];
    NSArray* allAlbumsArray = [allAlbumsQuery collections];
    
    NSMutableSet* localCollection = [[NSMutableSet alloc] init];
    
    // list all local albums
    for (MPMediaItemCollection* collection in allAlbumsArray) 
    {
        // list all local songs from albums
        for (MPMediaItem* item in collection.items)
        {
            Song* song = [[Song alloc] init];
            
            NSString* artistKey = [item valueForProperty:MPMediaItemPropertyArtist];
            NSString* albumKey = [item valueForProperty:MPMediaItemPropertyAlbumTitle];

            
            
            NSString* value = [item valueForProperty:MPMediaItemPropertyTitle];
            if (value == nil)
                song.name = [NSString stringWithString:PM_FIELD_UNKNOWN];
            else
                song.name = [NSString stringWithString:value];

            if (artistKey == nil)
            {
                artistKey = NSLocalizedString(@"ProgrammingView_unknownArtist", nil);
                song.artist = [NSString stringWithString:PM_FIELD_UNKNOWN];
            }
            else
                song.artist = [NSString stringWithString:artistKey];

            
            if (albumKey == nil)
            {
                albumKey =  NSLocalizedString(@"ProgrammingView_unknownAlbum", nil);
                song.album = [NSString stringWithString:PM_FIELD_UNKNOWN];
            }
            else
                song.album = [NSString stringWithString:albumKey];

            
            // create a key for the dictionary 
            NSString* key = [NSString stringWithFormat:@"%@|%@|%@", song.name, artistKey, albumKey];
            
            
            // don't include it if it's included in the matched songs already
            Song* matchedSong = [self.matchedSongs objectForKey:key];
            if (matchedSongs != nil)
                continue;
            
            [localCollection addObject:song];

        }
    }
    
    self.localSongs = [[NSMutableArray alloc] initWithArray:[localCollection allObjects]];
    [localCollection release];
    
    // PROFILE
    [[TimeProfile main] end];
    // PROFILE
    [[TimeProfile main] logInterval:@"Local Media Songs parsing"];

    
    NSLog(@"SongAddViewController : %d songs added to the local array", self.localSongs.count);
    
    NSString* subtitle = nil;
    if (self.localSongs.count == 0)
        subtitle = NSLocalizedString(@"SongAddView_subtitled_count_0", nil);
    else if (self.localSongs.count == 1)
        subtitle = NSLocalizedString(@"SongAddView_subtitled_count_1", nil);
    else if (self.localSongs.count > 1)
        subtitle = NSLocalizedString(@"SongAddView_subtitled_count_n", nil);
    
    subtitle = [subtitle stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", self.localSongs.count]];
    
    _subtitleLabel.text = subtitle;
    

    
    [ActivityAlertView close];
    
    
    
    
    
    
    if (self.localSongs.count == 0)
    {
        [_tableView removeFromSuperview];
        NSString* str = NSLocalizedString(@"PlaylistsView_empty_message", nil);
        _itunesConnectLabel.text = str;
        [self.view addSubview:_itunesConnectView];
        
        // IB, sometimes, is, huh.....
        [_itunesConnectView addSubview:_itunesConnectLabel];
        
    }

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
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return self.localSongs.count;
}



//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{    
//    return 44;
//}


//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 22;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 22;
//}








//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
//{
//    return gIndexMap;
//}
//
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index 
//{
//    return index;
//}




//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    NSString* title = nil;
//    
//    if (section == 0)
//        return nil;
//    
//    if (section == SECTION_MONTHCHART)
//        title = NSLocalizedString(@"StatsView_monthselector_label", nil);
//    
//    else if (section == SECTION_LEADERBOARD)
//        title = NSLocalizedString(@"StatsView_leaderboardselector_label", nil);
//    
//    
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MenuSection" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    
//    UIImage* image = [sheet image];
//    CGFloat height = image.size.height;
//    UIImageView* view = [[UIImageView alloc] initWithImage:image];
//    view.frame = CGRectMake(0, 0, tableView.bounds.size.width, height);
//    
//    sheet = [[Theme theme] stylesheetForKey:@"MenuSectionTitle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    UILabel* label = [sheet makeLabel];
//    label.text = title;
//    [view addSubview:label];
//    
//    return view;
//}




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

        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];

        // button "add"
        UIImage* image = [UIImage imageNamed:@"CellButtonAdd.png"];
        UIImageView* button = [[UIImageView alloc] initWithImage:image];
        button.frame = CGRectMake(cell.frame.size.width - image.size.width, 0, image.size.width, image.size.height);
        [cell addSubview:button];
        
        CGRect textFrame = cell.textLabel.frame;
        cell.textLabel.frame = CGRectMake(textFrame.origin.x, textFrame.origin.y, textFrame.size.width - button.frame.size.width, textFrame.size.height);
        textFrame = cell.detailTextLabel.frame;
        cell.detailTextLabel.frame = CGRectMake(textFrame.origin.x, textFrame.origin.y, textFrame.size.width - button.frame.size.width, textFrame.size.height);
    }

    Song* song = [self.localSongs objectAtIndex:indexPath.row];
    
    cell.textLabel.text = song.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", song.album, song.artist];
    
    

    // don't add the artwork now, but keep the code here in case of...
    //
//    MPMediaItemArtwork* artWork = [item valueForProperty:MPMediaItemPropertyArtwork];
//    UIImageView* image = [[UIImageView alloc] initWithImage:[artWork imageWithSize:CGSizeMake(30, 30)]];
//    CGRect frame = CGRectMake(8, 7, 30, 30);
//    image.frame = frame;
//    [cell addSubview:image];
//    
//    CGRect textFrame = cell.textLabel.frame;
//    cell.textLabel.frame = CGRectMake(textFrame.origin.x + frame.origin.x + frame.size.width, textFrame.origin.y, textFrame.size.width - frame.origin.x - frame.size.width, textFrame.size.height);
//    textFrame = cell.detailTextLabel.frame;
//    cell.detailTextLabel.frame = CGRectMake(textFrame.origin.x + frame.origin.x + frame.size.width, textFrame.origin.y, textFrame.size.width - frame.origin.x - frame.size.width, textFrame.size.height);
    
    
//    NSString *const MPMediaItemPropertyArtwork;
    
    return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    Song* song = [self.localSongs objectAtIndex:indexPath.row];

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
    
    // and remove the song from the current list
    [self.localSongs removeObjectAtIndex:indexPath.row];
    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [ActivityAlertView showWithTitle:NSLocalizedString(@"SongAddView_added", nil) closeAfterTimeInterval:1];
    
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

































