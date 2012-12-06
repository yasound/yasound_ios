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

@synthesize radio;

- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil playlistId:(NSInteger)playlistId forRadio:aRadio
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.radio = aRadio;
        
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
    [[YasoundDataProvider main] songsForPlaylist:_playlistId withCompletionBlock:^(int status, NSString* response, NSError* error){
        if (error)
        {
            DLog(@"songs for playlist %d error: %d - %@", _playlistId, error.code, error.domain);
            return;
        }
        if (status != 200)
        {
            DLog(@"songs for playlist %d error: response status %d", _playlistId, status);
            return;
        }
        Container* songContainer = [response jsonToContainer:[Song class]];
        if (!songContainer || !songContainer.objects)
        {
            DLog(@"songs for playlist %d error: cannot parse response %@", _playlistId, response);
            return;
        }
        NSArray* songs = songContainer.objects;
        [self buildSongsData:songs];
        [_tableView reloadData];
        [ActivityAlertView close];
    }];
    
}


- (void)buildSongsData:(NSArray *)songs
{
    if (_songs) {
        [_songs release];
    }
    _songs = [[NSArray alloc] initWithArray:songs];
}


-(void)uploadSongFinished
{
    [_hud hide:YES];
    [_hud release];
    [self refreshView];
}

-(void)uploadSong:(Song *)song 
{
    //Mat
    //#FIXME: Is this class still used
    // It cannot work...
    // WTF: uploadSong delegate param is MBProgressHUD object !!!
    assert(0);
    //
    
    
//    _hud = [[MBProgressHUD alloc] initWithView:self.view];
//	[self.navigationController.view addSubview:_hud];
//	
//    // Set determinate mode
//    _hud.mode = MBProgressHUDModeDeterminate;
//    
//    _hud.labelText = NSLocalizedString(@"SongsView_upload_progress", nil);
//
//    [_hud show:YES];
//    
//    [[SongUploader main] uploadSong:song.name forRadioId:self.radio.id
//                              album:song.album 
//                             artist:song.artist
//                             songId:song.id
//                             target:self 
//                             action:@selector(uploadSongFinished)
//                   progressDelegate:_hud];
}

#pragma mark - TableView Source and Delegate


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    if (section == 0) {
        return NSLocalizedString(@"SongsView_songs", nil);
    }
    return @"Wall.Header.Header";
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
        cell.detailTextLabel.text = NSLocalizedString(@"SongsView_synchronized", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    BOOL needSync = [song.need_sync boolValue];
    if (needSync) {
        cell.detailTextLabel.text = NSLocalizedString(@"SongsView_synchronization_in_progress", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    cell.detailTextLabel.text = NSLocalizedString(@"SongsView_click_to_synchronize", nil);
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
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SongsView_alert_cannot_upload", nil) message:NSLocalizedString(@"SongsView_alert_cannot_upload_message", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];  
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

#pragma mark - ActionSheet Delegate


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    if (buttonIndex == 0 && _selectedSong) {
        [self uploadSong:_selectedSong];
    }
}


@end
