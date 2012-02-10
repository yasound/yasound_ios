//
//  SongsViewController.m
//  Yasound
//
//  Created by Jérôme BLONDON on 09/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongsViewController.h"
#import "YasoundDataProvider.h"
#import "ActivityAlertView.h"
#import "SongUploader.h"

@implementation SongsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil playlistId:(NSInteger)playlistId
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _playlistId = playlistId;
        [self resetArrays];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshView];
}

- (void)viewDidUnload
{
    [_needSyncSongs release];
    [_matchedSongs release];
    [_unmatchedSongs release];
    [_protectedSongs release];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Private methods

- (void)resetArrays
{
    if(_needSyncSongs) {
        [_needSyncSongs release];
    }
    
    if (_matchedSongs) {
        [_matchedSongs release];
    }
    
    if (_unmatchedSongs) {
        [_unmatchedSongs release];
    }

    if (_protectedSongs) {
        [_protectedSongs release];
    }
    
    _matchedSongs = [[NSMutableArray alloc] init ];
    [_matchedSongs retain];
    
    _unmatchedSongs = [[NSMutableArray alloc] init ];
    [_unmatchedSongs retain];
    
    _needSyncSongs = [[NSMutableArray alloc] init ];
    [_needSyncSongs retain];

    _protectedSongs = [[NSMutableArray alloc] init ];
    [_protectedSongs retain];
}

- (void)refreshView
{
    [ActivityAlertView showWithTitle:NSLocalizedString(@"Alert_contact_server", nil)];
    [self resetArrays];
    [[YasoundDataProvider main] songsForPlaylist:_playlistId target:self action:@selector(receiveSongs:withInfo:)];
}


- (void)buildSongsData:(NSArray *)songs
{
    SongUploader *songUploader = [SongUploader main];
    
    // split data between matched, unmatched, sync in progress songs
    for (Song *song in songs) {
        if ([song.song isKindOfClass:[NSNumber class]]) {
            [_matchedSongs addObject:song];
            continue;
        }
        
        if (![songUploader canUploadSong:song.name album:song.album artist:song.artist]) {
            [_protectedSongs addObject:song];
            continue;
        }
        
        BOOL needSync = [song.need_sync boolValue];
        if (needSync) {
            [_needSyncSongs addObject:song];
            continue;
        }

        [_unmatchedSongs addObject:song];
    }
}

-(void)uploadSongFinished
{
    [ActivityAlertView close];
    [self refreshView];
}

-(void)uploadSong:(Song *)song 
{
    [ActivityAlertView showWithTitle:NSLocalizedString(@"Alert_contact_server", nil)];
    [[SongUploader main] uploadSong:song.name 
                              album:song.album 
                             artist:song.artist
                             songId:song.id
                             target:self 
                             action:@selector(uploadSongFinished)];
}

#pragma mark - TableView Source and Delegate


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    if (section == 0) {
        return NSLocalizedString(@"SongsView_unmatched_songs", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"SongsView_matched_songs", nil);
    } else if (section == 2) { 
        return NSLocalizedString(@"SongsView_need_sync_songs", nil);
    } else if (section == 3) { 
        return NSLocalizedString(@"SongsView_protected_songs", nil);
    }
    return @"Header";
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == 0) {
        return [_unmatchedSongs count];
    } else if (section == 1){ 
        return [_matchedSongs count];
    } else if (section == 2) { 
        return [_needSyncSongs count];
    } else if (section == 3) { 
        return [_protectedSongs count];
    }
    return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{

    NSMutableArray *source = NULL;
    if (indexPath.section == 0) {
        source = _unmatchedSongs;
    } else if (indexPath.section == 1) {
        source = _matchedSongs;
    } else if (indexPath.section == 2) {
        source = _needSyncSongs;
    } else if (indexPath.section == 3) {
        source = _protectedSongs;
    }
    
    static NSString* CellIdentifier = @"SongCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    Song *song = [source objectAtIndex:indexPath.row];
    cell.textLabel.text = song.name;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0) {
        return;
    }

    NSMutableArray *source = NULL;
    if (indexPath.section == 0) {
        source = _unmatchedSongs;
    } else if (indexPath.section == 1) {
        source = _matchedSongs;
    } else if (indexPath.section == 2) {
        source = _needSyncSongs;
    } else if (indexPath.section == 3) {
        source = _protectedSongs;
    }
    
    _selectedSong = [source objectAtIndex:indexPath.row];
    if (!_selectedSong) {
        return;
    }
    
    UIActionSheet* popupQuery = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SongsView_confirm_upload", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"SongsView_cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"SongsView_upload_songs", nil), nil];
    
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [popupQuery showInView:self.view];
    [popupQuery release];
    

}

#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - YasoundDataProvider callbacks

- (void)receiveSongs:(NSArray*)songs withInfo:(NSDictionary*)info
{
    [self buildSongsData:songs];
    [_tableView reloadData];
    [ActivityAlertView close];
}

#pragma mark - ActionSheet Delegate


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    if (buttonIndex == 0 && _selectedSong) {
        [self uploadSong:_selectedSong];
    }
}


@end
