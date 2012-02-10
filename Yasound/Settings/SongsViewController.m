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
    [_songs release];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Private methods

- (void)refreshView
{
    [ActivityAlertView showWithTitle:NSLocalizedString(@"Alert_contact_server", nil)];
    [[YasoundDataProvider main] songsForPlaylist:_playlistId target:self action:@selector(receiveSongs:withInfo:)];
}


- (void)buildSongsData:(NSArray *)songs
{
    if (_songs) {
        [_songs release];
    }
    _songs = [[NSArray alloc] initWithArray:songs];
}
//    SongUploader *songUploader = [SongUploader main];
//    
//    // split data between matched, unmatched, sync in progress songs
//    for (Song *song in songs) {
//        if ([song.song isKindOfClass:[NSNumber class]]) {
//            [_matchedSongs addObject:song];
//            continue;
//        }
//        
//        if (![songUploader canUploadSong:song.name album:song.album artist:song.artist]) {
//            [_protectedSongs addObject:song];
//            continue;
//        }
//        
//        BOOL needSync = [song.need_sync boolValue];
//        if (needSync) {
//            [_needSyncSongs addObject:song];
//            continue;
//        }
//
//        [_unmatchedSongs addObject:song];
//    }

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
        return NSLocalizedString(@"SongsView_songs", nil);
    }
    return @"Header";
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == 0) {
        return [_songs count];
    }
    return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString* CellIdentifier = @"SongCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    Song *song = [_songs objectAtIndex:indexPath.row];
    cell.textLabel.text = song.name;
    
    if ([song.song isKindOfClass:[NSNumber class]]) {
        cell.detailTextLabel.text = @"synchronized";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    SongUploader *songUploader = [SongUploader main];
    if (![songUploader canUploadSong:song.name album:song.album artist:song.artist]) {
        cell.detailTextLabel.text = @"protected";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    BOOL needSync = [song.need_sync boolValue];
    if (needSync) {
        cell.detailTextLabel.text = @"synchronization in progress";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    cell.detailTextLabel.text = @"click to synchronize";
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedSong = [_songs objectAtIndex:indexPath.row];
    if (!_selectedSong) {
        return;
    }
    if ([_selectedSong.song isKindOfClass:[NSNumber class]]) {
        return;
    }
    SongUploader *songUploader = [SongUploader main];
    if (![songUploader canUploadSong:_selectedSong.name album:_selectedSong.album artist:_selectedSong.artist]) {
        return;
    }
    BOOL needSync = [_selectedSong.need_sync boolValue];
    if (needSync) {
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
