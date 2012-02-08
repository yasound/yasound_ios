//
//  PlaylistsViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 21/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "PlaylistsViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ActivityAlertView.h"
#import "RadioViewController.h"
#import "PlaylistMoulinor.h"
#import "YasoundDataProvider.h"
#import "RootViewController.h"
#import "YasoundDataProvider.h"
#import "UIDevice+IdentifierAddition.h"

#import "SongUploader.h"

@implementation PlaylistsViewController

- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil wizard:(BOOL)wizard
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _wizard = wizard;
        
        _changed = NO;
        if (_wizard)
            _changed = YES;
        
        //......................................................................................
        // init playlists
        //
        MPMediaQuery *playlistsquery = [MPMediaQuery playlistsQuery];
        _playlistsDesc = [[NSMutableArray alloc] init];
        [_playlistsDesc retain];
        _playlists = [playlistsquery collections];
        [_playlists retain];

        Radio* radio = [YasoundDataProvider main].radio;
        [[YasoundDataProvider main] playlistsForRadio:radio 
                                               target:self 
                                               action:@selector(receivePlaylists:withInfo:)
         ];
        
        _selectedPlaylists = [[NSMutableArray alloc] init];
        [_selectedPlaylists retain];
    }
    
    return self;
}

-(NSMutableDictionary *)findPlayListByName:(NSString *)name withSource:(NSString *)source
{
    for (NSMutableDictionary *item in _playlistsDesc) {
        NSString* aName = [item objectForKey:@"name"];
        NSString* aSource = [item objectForKey:@"source"];
        if ([name isEqualToString:aName] && [source isEqualToString:aSource]) {
            return item;
        }
    }
    return NULL;
}

- (void)buildPlaylistData:(NSArray *)localPlaylists withRemotePlaylists:(NSArray *)remotePlaylists
{
    for (Playlist *playlist in remotePlaylists) {
        NSString* name = playlist.name;
        NSString* source = playlist.source;
        NSNumber* count = playlist.song_count;
        NSNumber* matched = playlist.matched_song_count;
        NSNumber* unmatched = playlist.unmatched_song_count;
        
        NSMutableDictionary* dico = [[NSMutableDictionary alloc] init];
        [dico setObject:name forKey:@"name"];
        [dico setObject:source forKey:@"source"];
        [dico setObject:count forKey:@"count"];
        [dico setObject:matched forKey:@"matched"];
        [dico setObject:unmatched forKey:@"unmatched"];
        [_playlistsDesc addObject:dico];
    }
    
    NSString *source = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    for (MPMediaPlaylist *playlist in localPlaylists) {
        NSString* name = [playlist valueForProperty: MPMediaPlaylistPropertyName];
        NSNumber* count = [NSNumber numberWithInteger:[playlist count]];
        NSNumber* localPlaylistIndex = [NSNumber numberWithInt:[localPlaylists indexOfObject:playlist]];
        
        NSMutableDictionary *dico = [self findPlayListByName:name withSource:source];
        if (dico) {
            [dico setObject:count forKey:@"count"];
            [dico setObject:localPlaylistIndex forKey:@"localPlaylistIndex"];
        } else {
            NSMutableDictionary* dico = [[NSMutableDictionary alloc] init];
            [dico setObject:name forKey:@"name"];
            [dico setObject:count forKey:@"count"];
            [dico setObject:localPlaylistIndex forKey:@"localPlaylistIndex"];
            [_playlistsDesc addObject:dico];
        }
    }
}

- (void)receivePlaylists:(NSArray*)playlists withInfo:(NSDictionary*)info
{
    [self buildPlaylistData:_playlists withRemotePlaylists:playlists];
    [self refreshView];
}

                                                                                      
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)dealloc
{
    [_playlists release];
    [_playlistsDesc release];
    [_selectedPlaylists release];

    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _titleLabel.text = NSLocalizedString(@"PlaylistsView_title", nil);
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);

    BOOL forceEnableNextBtn = NO;
    
#if TARGET_IPHONE_SIMULATOR
    forceEnableNextBtn = YES;
#endif

    
    // next button in toolbar
    if (_wizard)
    {
        UIBarButtonItem* backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Navigation_cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(onBack:)];

        _nextBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Navigation_next", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(onNext:)];

        UIBarButtonItem* space=  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];


//        NSMutableArray* items = [NSMutableArray arrayWithArray:_toolbar.items];
        NSMutableArray* items = [[NSMutableArray alloc] init];
        
        [items addObject:backBtn];
        [items addObject:space];
        [items addObject:_nextBtn];
        
        [_toolbar setItems:items animated:NO];
        
        if (([_playlists count] != 0) || forceEnableNextBtn)
            _nextBtn.enabled = YES;
        else
            _nextBtn.enabled = NO;
    }
    
    
    _cellHowtoLabel.text = NSLocalizedString(@"PlaylistsView_howto", nil);
    [self refreshView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)refreshView
{
    if ([_playlistsDesc count] == 0)
    {
        [_tableView removeFromSuperview];
        _itunesConnectLabel.text = NSLocalizedString(@"PlaylistsView_empty_message", nil);
        [_container addSubview:_itunesConnectView];
    } else {
        [_itunesConnectView removeFromSuperview];
        [self.view addSubview:_tableView];
    }
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
    return 2;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == 1)
    {
        NSInteger nbRows = [_playlistsDesc count];
        return nbRows;
    }
    
    return 1;
}


//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
//{
//    if (tableView == _settingsTableView)
//        [self willDisplayCellInSettingsTableView:cell forRowAtIndexPath:indexPath];
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.section == 0)
        return _cellHowto;
    
    
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSLog(@"ROW  section %d   row %d", indexPath.section, indexPath.row);
    
    NSDictionary* dico = [_playlistsDesc objectAtIndex:indexPath.row];
    cell.textLabel.text = [dico objectForKey:@"name"];
    
    NSDictionary *selectedItem = [_playlistsDesc objectAtIndex:indexPath.row];
    NSNumber *localPlaylistIndex = [selectedItem objectForKey:@"localPlaylistIndex"];
    if (localPlaylistIndex != NULL) {
        
        if ([_selectedPlaylists containsObject:[_playlists objectAtIndex:[localPlaylistIndex integerValue]]] || _wizard)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSNumber *matched = [dico objectForKey:@"matched"];
    NSNumber *unmatched = [dico objectForKey:@"unmatched"];
    
    if (matched != NULL && unmatched != NULL) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d (%d+%d) songs", 
                                     [[dico objectForKey:@"count"] integerValue],
                                     [matched integerValue],
                                     [unmatched integerValue]];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d songs", [[dico objectForKey:@"count"] integerValue]];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *item = [_playlistsDesc objectAtIndex:indexPath.row];
    NSNumber *localPlaylistIndex = [item objectForKey:@"localPlaylistIndex"];
    if (localPlaylistIndex == NULL) {
        return;
    }
    
    MPMediaPlaylist* list = [_playlists objectAtIndex:[localPlaylistIndex integerValue]];
    
    if ([_selectedPlaylists containsObject:list] == YES)
    {
        NSLog(@"deselect\n");
        [_selectedPlaylists removeObject:list];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if ([_selectedPlaylists count] == 0)
            [_nextBtn setEnabled:NO];

    }
    else
    {
        NSLog(@"select\n");
        [_selectedPlaylists addObject:list];
        cell.accessoryType = UITableViewCellAccessoryCheckmark; 

        [_nextBtn setEnabled:YES];
    }
    
    cell.selected = FALSE;
    _changed = YES;
}







#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    if (_wizard)
    {
        // call root to launch the Radio
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO_SELECTION object:nil];
        return;
    }
    
    // save or cancel
    if (!_wizard && _changed)
    {
        UIActionSheet* popupQuery = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SettingsView_saveOrCancel_title", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"SettingsView_saveOrCancel_cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"SettingsView_saveOrCancel_save", nil), nil];
        
        popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [popupQuery showInView:self.view];
        [popupQuery release];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (IBAction)onNext:(id)sender
{
    [self save];
}






#pragma mark - ActionSheet Delegate


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    if (buttonIndex == 0)
        [self save];
    else
        [self.navigationController popViewControllerAnimated:YES];        
}



- (void) save
{
    //fake commnunication
    [ActivityAlertView showWithTitle:NSLocalizedString(@"PlaylistsView_submit_title", nil)];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    //    
    [[PlaylistMoulinor main] buildDataWithPlaylists:_selectedPlaylists binary:YES compressed:YES target:self action:@selector(didBuildDataWithPlaylist:)];
    
//    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(onFakeSubmitAction:) userInfo:nil repeats:NO];
}



- (void) didBuildDataWithPlaylist:(NSData*)data
{
    //LBDEBUG email playlist file
    //  [[PlaylistMoulinor main] emailData:data to:@"neywen@neywen.net" mimetype:@"application/octet-stream" filename:@"yasound_playlist.bin" controller:self];

    //LBDEBUG
    Radio* radio = [YasoundDataProvider main].radio;
    NSLog(@"radio %@", radio.name);
  [[YasoundDataProvider main] updatePlaylists:data forRadio:radio target:self action:@selector(receiveUpdatePLaylistsResponse:error:)];
    //[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(onFakeSubmitAction:) userInfo:nil repeats:NO];

    //LBDEBUG
    //[self onFakeSubmitAction:nil];
    
}


- (void)receiveUpdatePLaylistsResponse:(taskID)task_id error:(NSError*)error
{
  if (error)
    NSLog(@"update playlists error %d", error.code);
  else
    NSLog(@"playlists updated  task: %@", task_id);
    
    taskTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkPlaylistTask:) userInfo:task_id repeats:YES];
}

- (void)checkPlaylistTask:(NSTimer*)timer
{
    taskID task = timer.userInfo;
    [[YasoundDataProvider main] taskStatus:task target:self action:@selector(receiveTaskStatus:error:)];
}

- (void)receiveTaskStatus:(taskStatus)status error:(NSError*) error
{
    if (status == eTaskSuccess)
    {
        [taskTimer invalidate];
        [self onFakeSubmitAction:nil];
    }
    else if (status == eTaskFailure)
    {
        [taskTimer invalidate];
        [self onFakeSubmitAction:nil];
    }
}


//LBDEBUG
- (void)onFakeSubmitAction:(NSTimer*)timer
{
    [ActivityAlertView close];
    
    if (_wizard)
    {
        // call root to launch the Radio
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:nil];
    }
    else
        [self.navigationController popViewControllerAnimated:YES];
}


@end
