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


#define PM_FIELD_UNKNOWN @""
#define BORDER 8

@implementation SongAddViewController


@synthesize  localSongs;
@synthesize remoteSongs;
@synthesize matchedSongs;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withMatchedSongs:(NSArray*)matchedSongs
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.localSongs = [[NSMutableArray alloc] init];
        self.matchedSongs = matchedSongs;
    }
    return self;
}


- (BOOL)doesArrayContainSong:(NSArray*)array song:(Song*)aSong
{
    for (Song* song in array)
    {
        if (![song.name isEqualToString:aSong.name])
            continue;
        
        if (![song.album isEqualToString:aSong.album])
            continue;

        if (![song.artist isEqualToString:aSong.artist])
            continue;
        
        return YES;
    }
    
    return NO;
}




- (void)viewDidLoad
{
    [super viewDidLoad];

    _titleLabel.text = NSLocalizedString(@"SongAddView_title", nil);
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
    
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    
    
    [ActivityAlertView showWithTitle:NSLocalizedString(@"SongAddView_alert", nil)];        
    
    
    [[TimeProfile main] begin];
    
    
    MPMediaQuery* allAlbumsQuery = [MPMediaQuery albumsQuery];
    NSArray* allAlbumsArray = [allAlbumsQuery collections];
    
    // list all local albums
    for (MPMediaItemCollection* collection in allAlbumsArray) 
    {
        // list all local songs from albums
        for (MPMediaItem* item in collection.items)
        {
            Song* song = [[Song alloc] init];
            
            song.name = [NSString stringWithString:[item valueForProperty:MPMediaItemPropertyTitle]];
            if (song.name == nil)
                song.name = [NSString stringWithString:PM_FIELD_UNKNOWN];
            
            song.artist = [NSString stringWithString:[item valueForProperty:MPMediaItemPropertyArtist]];
            if (song.artist == nil)
                song.artist = [NSString stringWithString:PM_FIELD_UNKNOWN];
            
            song.album  = [NSString stringWithString:[item valueForProperty:MPMediaItemPropertyAlbumTitle]];
            if (song.album == nil)
                song.album = [NSString stringWithString:PM_FIELD_UNKNOWN];
            
            
            // don't include it if it's included in the matched songs already
            if ([self doesArrayContainSong:matchedSongs song:song])
                continue;
            
            [self.localSongs addObject:song];
        }
    }
    
    [[TimeProfile main] end];
    
    NSLog(@"SongAddViewController : %d songs added to the local array", self.localSongs.count);
    [[TimeProfile main] logInterval];
    
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
    
//    MPMediaItem* item = [self.localSongs objectAtIndex:indexPath.row];
//    
//    // retrieve media item's info
//    NSString* song = [item valueForProperty:MPMediaItemPropertyTitle];
//    if (song == nil)
//        song = [NSString stringWithString:PM_FIELD_UNKNOWN];
//    NSString* artist = [item valueForProperty:MPMediaItemPropertyArtist];
//    if (artist == nil)
//        artist = [NSString stringWithString:PM_FIELD_UNKNOWN];
//    NSString* album  = [item valueForProperty:MPMediaItemPropertyAlbumTitle];  
//    if (album == nil)
//        album = [NSString stringWithString:PM_FIELD_UNKNOWN];

    
//    cell.textLabel.text = song;
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", album, artist];
    
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
//    MPMediaItem* item = [self.localSongs objectAtIndex:indexPath.row];

//    Song* song = [[Song alloc] init];
//    
//    song.name = [NSString stringWithString:[item valueForProperty:MPMediaItemPropertyTitle]];
//    if (song.name == nil)
//        song.name = [NSString stringWithString:PM_FIELD_UNKNOWN];
//    
//    song.artist = [NSString stringWithString:[item valueForProperty:MPMediaItemPropertyArtist]];
//    if (song.artist == nil)
//        song.artist = [NSString stringWithString:PM_FIELD_UNKNOWN];
//    
//    song.album  = [NSString stringWithString:[item valueForProperty:MPMediaItemPropertyAlbumTitle]];
//    if (song.album == nil)
//        song.album = [NSString stringWithString:PM_FIELD_UNKNOWN];

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
    
    [song autorelease];
}
















#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end

































