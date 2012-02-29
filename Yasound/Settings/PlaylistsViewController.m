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
#import "SongsViewController.h"
#import "ActivityAlertView.h"
#import "SettingsViewController.h"
#import "SongUploader.h"

#import "BundleFileManager.h"
#import "Theme.h"

@implementation PlaylistsViewController

- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil wizard:(BOOL)wizard
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
      
        _displayMode = eDisplayModeNormal;
        _wizard = wizard;
        _songsViewController = nil;
        _changed = NO;
        if (_wizard)
            _changed = YES;
        
        _checkmarkImage = [UIImage imageNamed:@"WhiteCheckmark.png"];
        [_checkmarkImage retain];
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
    for (Playlist* playlist in remotePlaylists) 
    {
        NSNumber* playlistId = [NSNumber numberWithInteger:playlist.id];
        NSString* name = playlist.name;
        NSString* source = playlist.source;
        NSNumber* count = playlist.song_count;
        NSNumber* matched = playlist.matched_song_count;
        NSNumber* unmatched = playlist.unmatched_song_count;
        NSNumber* enabled = playlist.enabled;
        NSNumber* neverSynchronized = [NSNumber numberWithBool:FALSE];
        
        NSMutableDictionary* dico = [[NSMutableDictionary alloc] init];
        [dico setObject:playlistId forKey:@"playlistId"];
        [dico setObject:name forKey:@"name"];
        [dico setObject:source forKey:@"source"];
        [dico setObject:count forKey:@"count"];
        [dico setObject:matched forKey:@"matched"];
        [dico setObject:unmatched forKey:@"unmatched"];
        [dico setObject:neverSynchronized forKey:@"neverSynchronized"];
        [dico setObject:enabled forKey:@"enabled"];
        [_playlistsDesc addObject:dico];
    }
    
    NSString *source = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    for (MPMediaPlaylist *playlist in localPlaylists) {
        NSString* name = [playlist valueForProperty: MPMediaPlaylistPropertyName];
        NSNumber* count = [NSNumber numberWithInteger:[playlist count]];

        NSMutableDictionary *dico = [self findPlayListByName:name withSource:source];
        if (dico) {
            // existing playlist on device and on remote server
            [dico setObject:count forKey:@"count"];
            [dico setObject:playlist forKey:@"mediaPlaylist"];
        } else {
            // new playlist on local device
            NSNumber* neverSynchronized = [NSNumber numberWithBool:YES];
            NSNumber* enabled = [NSNumber numberWithBool:NO];
            NSMutableDictionary* dico = [[NSMutableDictionary alloc] init];
            [dico setObject:name forKey:@"name"];
            [dico setObject:count forKey:@"count"];
            [dico setObject:playlist forKey:@"mediaPlaylist"];
            [dico setObject:count forKey:@"count"];
            [dico setObject:neverSynchronized forKey:@"neverSynchronized"];
            [dico setObject:source forKey:@"source"];
            [dico setObject:enabled forKey:@"enabled"];
            [_playlistsDesc addObject:dico];
        }
    }
    
    for (NSDictionary *dico in _playlistsDesc) 
    {
        MPMediaPlaylist *mediaPlaylist = [dico objectForKey:@"mediaPlaylist"]; 
        NSNumber* enabled = [dico objectForKey:@"enabled"];
        
        if (mediaPlaylist) 
            [_localPlaylistsDesc addObject:dico];
        else
            [_remotePlaylistsDesc addObject:dico];

        if (_wizard) 
        {
            if (mediaPlaylist)
                [_selectedPlaylists addObject:dico];
        }
        else 
        {
            if ([enabled boolValue] == FALSE)
                [_unselectedPlaylists addObject:dico];
            else
                [_selectedPlaylists addObject:dico];
        }
    }
}

- (void)receivePlaylists:(NSArray*)playlists withInfo:(NSDictionary*)info
{
    [self buildPlaylistData:_playlists withRemotePlaylists:playlists];
    [self refreshView];

    [ActivityAlertView close];
}

                                                                                      
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)dealloc
{
    [_checkmarkImage release];
    [_howto release];
    if (_songsViewController) {
        [_songsViewController release];
    }
    [_localPlaylistsDesc release];
    [_remotePlaylistsDesc release];
    [_playlists release];
    [_playlistsDesc release];
    [_selectedPlaylists release];
    [_unselectedPlaylists release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _titleLabel.text = NSLocalizedString(@"PlaylistsView_title", nil);
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);

    _forceEnableNextBtn = NO;
    
#if TARGET_IPHONE_SIMULATOR
    _forceEnableNextBtn = YES;
#endif

    
    // next button in toolbar
    if (_wizard)
    {
        UIBarButtonItem* backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Navigation_cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(onBack:)];

        _nextBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Navigation_next", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(onNext:)];

        UIBarButtonItem* space=  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];


        NSMutableArray* items = [[NSMutableArray alloc] init];
        
        [items addObject:backBtn];
        [items addObject:space];
        [items addObject:_nextBtn];
        
        [_toolbar setItems:items animated:NO];
        
        _nextBtn.enabled = NO;

        
    } 
    else 
    {
        UIBarButtonItem* backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Navigation_back", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(onBack:)];
  
      // For the moment we disable playlist editing until we have a better solution.
//        UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(onEdit:)];
        
        UIBarButtonItem* space=  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        NSMutableArray* items = [[NSMutableArray alloc] init];
        
        [items addObject:backBtn];
        [items addObject:space];
//        [items addObject:edit];
        
        [_toolbar setItems:items animated:NO];
        
    }
    
    _howto = NSLocalizedString(@"PlaylistsView_howto", nil);
    [_howto retain];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"PlaylistsView_Howto" error:nil];
    UIFont* font = [sheet makeFont];
    
    // dynamic size of howto text
    CGSize suggestedSize = [_howto sizeWithFont:font constrainedToSize:CGSizeMake(sheet.frame.size.width, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    _cellHowtoHeight = suggestedSize.height;
    
    
    
    //......................................................................................
    // init playlists
    //

    [ActivityAlertView showWithTitle: NSLocalizedString(@"PlaylistsViewController_FetchingPlaylists", nil)];
    
    MPMediaQuery *playlistsquery = [MPMediaQuery playlistsQuery];
    _playlistsDesc = [[NSMutableArray alloc] init];
    [_playlistsDesc retain];
    _playlists = [playlistsquery collections];
    [_playlists retain];
    
    if (([_playlists count] != 0) || _forceEnableNextBtn)
        _nextBtn.enabled = YES;
    else
        _nextBtn.enabled = NO;
    
    
    [self.view addSubview:_tableView];
    
    Radio* radio = [YasoundDataProvider main].radio;
    [[YasoundDataProvider main] playlistsForRadio:radio 
                                           target:self 
                                           action:@selector(receivePlaylists:withInfo:)
     ];
    
    _selectedPlaylists = [[NSMutableArray alloc] init];
    [_selectedPlaylists retain];
    
    _unselectedPlaylists = [[NSMutableArray alloc] init];
    [_unselectedPlaylists retain];
    
    _localPlaylistsDesc = [[NSMutableArray alloc] init];
    [_localPlaylistsDesc retain];
    
    _remotePlaylistsDesc = [[NSMutableArray alloc] init];
    [_remotePlaylistsDesc retain];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
        [_tableView reloadData];
    }
}







#pragma mark - TableView Source and Delegate


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
//{
//    if (section == 1) {
//        return NSLocalizedString(@"PlaylistsView_table_header_local_playlists", nil);
//    } else if (section == 2) {
//        return NSLocalizedString(@"PlaylistsView_table_header_other_playlists", nil);
//    }
//    return nil;
//}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == 1)
    {
        NSInteger nbRows = [_localPlaylistsDesc count];
        return nbRows;
    }
    else if (section == 2) {
        NSInteger nbRows = [_remotePlaylistsDesc count];
        return nbRows;
    }
    
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
        return 0;
    
    return 22;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) 
        return _cellHowtoHeight;
    
    return 44;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}




- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString* title = nil;
    
    if (section == 0)
        return nil;
    
    if (section == 1)
        title = NSLocalizedString(@"PlaylistsView_table_header_local_playlists", nil);
    
    else if (section == 2)
        title = NSLocalizedString(@"PlaylistsView_table_header_other_playlists", nil);

    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MenuSection" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    
    UIImage* image = [sheet image];
    CGFloat height = image.size.height;
    UIImageView* view = [[UIImageView alloc] initWithImage:image];
    view.frame = CGRectMake(0, 0, tableView.bounds.size.width, height);
    
    sheet = [[Theme theme] stylesheetForKey:@"MenuSectionTitle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = title;
    [view addSubview:label];
    
    return view;
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ((indexPath.section == 0) && (indexPath.row == 0))
    {
        UIView* view = [[UIView alloc] initWithFrame:cell.frame];
        view.backgroundColor = [UIColor clearColor];
        cell.backgroundView = view;
        [view release];
        return;
    }
    
    NSInteger nbRows;
    if (indexPath.section == 1)
    {
        nbRows = [_localPlaylistsDesc count];
    }
    else if (indexPath.section == 2) 
    {
        nbRows = [_remotePlaylistsDesc count];
    }
    
    if (nbRows == 1)
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowSingle.png"]];
        cell.backgroundView = view;
        [view release];
    }
    else if (indexPath.row == 0)
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowFirst.png"]];
        cell.backgroundView = view;
        [view release];
    }
    else if (indexPath.row == (nbRows -1))
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowLast.png"]];
        cell.backgroundView = view;
        [view release];
    }
    else
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowInter.png"]];
        cell.backgroundView = view;
        [view release];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.section == 0)
    {
        static NSString* CellIdentifier = @"CellHowto";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) 
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"PlaylistsView_Howto" error:nil];

        UILabel* label = [sheet makeLabel];
        label.text = _howto;
        label.numberOfLines = 0;
        label.frame = CGRectMake(sheet.frame.origin.x, sheet.frame.origin.y, sheet.frame.size.width, _cellHowtoHeight);
        [cell addSubview:label];

        return cell;
    }
    
    
    
    NSMutableArray *source = nil;
    
    if (indexPath.section == 1) 
        source = _localPlaylistsDesc;
    else if (indexPath.section == 2)
        source = _remotePlaylistsDesc;
    
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary* dico = [source objectAtIndex:indexPath.row];
  
    BOOL neverSynchronized = [(NSNumber *)[dico objectForKey:@"neverSynchronized"] boolValue];
    cell.textLabel.text = [dico objectForKey:@"name"];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    
    NSDictionary* selectedItem = [source objectAtIndex:indexPath.row];
    MPMediaPlaylist* mediaPlaylist = [selectedItem objectForKey:@"mediaPlaylist"];

    
    [self checkmark:cell with:NO];
    if (_displayMode == eDisplayModeNormal) 
    {
        if ([_unselectedPlaylists containsObject:dico]) 
            [self checkmark:cell with:NO];
        else
            [self checkmark:cell with:YES];

    } 
    else if (_displayMode == eDisplayModeEdit) 
    {
        if (mediaPlaylist != NULL && neverSynchronized == FALSE) 
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSNumber* matched = [dico objectForKey:@"matched"];
    NSNumber* unmatched = [dico objectForKey:@"unmatched"];
    
    if (matched != NULL && unmatched != NULL) {
        cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"PlaylistsView_cell_detail_with_matched", nil), 
                                     [matched integerValue],
                                     [[dico objectForKey:@"count"] integerValue]];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"PlaylistsView_cell_detail",nil), [[dico objectForKey:@"count"] integerValue]];
    }
//    if (neverSynchronized) {
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (never synchronized)",
//                                     cell.detailTextLabel.text];
//    } else {
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (synchronized)",
//                                     cell.detailTextLabel.text];
//    }
    
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];

    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return;
    _changed = YES;
    
    NSMutableArray* source = NULL;
    if (indexPath.section == 1) 
        source = _localPlaylistsDesc;
    else if (indexPath.section == 2) 
        source = _remotePlaylistsDesc;

    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = FALSE;
    
    NSDictionary* playlistDico = [source objectAtIndex:indexPath.row];
    MPMediaPlaylist* mediaPlaylist = [playlistDico objectForKey:@"mediaPlaylist"];
    
    if (mediaPlaylist == NULL) 
    {
        // special handler for remote playlists
        if ([_unselectedPlaylists containsObject:playlistDico] == YES)
        {
            [_unselectedPlaylists removeObject:playlistDico];
            [_selectedPlaylists addObject:playlistDico];
            [self checkmark:cell with:YES];
        }
        else
        {
            [_unselectedPlaylists addObject:playlistDico];
            [_selectedPlaylists removeObject:playlistDico];
            [self checkmark:cell with:NO];
        }
        return;
    }
    
    // handler for local playlists
    
    if (_displayMode == eDisplayModeEdit) 
    {
        // display detailed view about playlist
        BOOL neverSynchronized = [(NSNumber *)[playlistDico objectForKey:@"neverSynchronized"] boolValue];
        if (neverSynchronized) 
          return;
      
        if (_songsViewController) 
            [_songsViewController release];

        NSNumber *playlistId = [playlistDico objectForKey:@"playlistId"];
        _songsViewController = [[SongsViewController alloc] initWithNibName:@"SongsViewController" bundle:nil playlistId:[playlistId integerValue]];    
        [self.navigationController pushViewController:_songsViewController animated:TRUE];
        return;
    }
    
    if ([_unselectedPlaylists containsObject:playlistDico] == YES)
    {
        [_unselectedPlaylists removeObject:playlistDico];
        [_selectedPlaylists addObject:playlistDico];
        [self checkmark:cell with:YES];
    }
    else
    {
        [_unselectedPlaylists addObject:playlistDico];
        [_selectedPlaylists removeObject:playlistDico];
        [self checkmark:cell with:NO];
    }
    
    if ([_selectedPlaylists count] == 0)
        [_nextBtn setEnabled:NO];
    else 
        [_nextBtn setEnabled:YES];
}



- (void)checkmark:(UITableViewCell*)cell with:(BOOL)value
{
    if (value)
    {
        UIImageView *checkmark = [[UIImageView alloc] initWithImage:_checkmarkImage];
        cell.accessoryView = checkmark;
        [checkmark release];
        return;
    }
    
    cell.accessoryView = nil;
}



#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    if (_wizard)
    {
        // call root to launch the Radio
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CANCEL_WIZARD object:nil];
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

- (IBAction)onEdit:(id)sender
{
    if (_displayMode == eDisplayModeNormal) {
        _displayMode = eDisplayModeEdit;
    } else {
        _displayMode = eDisplayModeNormal;
    }
    [_tableView reloadData];
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
    [ActivityAlertView showWithTitle:NSLocalizedString(@"PlaylistsView_submit_title", nil) message:@"..."];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    //    
    [[PlaylistMoulinor main] buildDataWithPlaylists:_selectedPlaylists
                                   removedPlaylists:_unselectedPlaylists
                                             binary:YES 
                                         compressed:YES 
                                             target:self 
                                             action:@selector(didBuildDataWithPlaylist:)];
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

- (void)receiveTaskStatus:(TaskInfo*)taskInfo error:(NSError*) error
{
    if (taskInfo.status == eTaskSuccess)
    {
        [taskTimer invalidate];
        [self onFakeSubmitAction:nil];
    }
    else if (taskInfo.status == eTaskFailure)
    {
        [taskTimer invalidate];
        [self onFakeSubmitAction:nil];
    }
  else if (taskInfo.status == eTaskPending)
  {
    NSString* msg = [NSString stringWithFormat:@"%d%%", (int)(taskInfo.progress * 100)];
    if (taskInfo.message)
      msg = [msg stringByAppendingFormat:@" - %@", taskInfo.message];
    [ActivityAlertView current].message = msg;
  }
}


//LBDEBUG
- (void)onFakeSubmitAction:(NSTimer*)timer
{
  // be sure to get updated radio (with correct 'ready' flag)
  [[YasoundDataProvider main] userRadioWithTarget:self action:@selector(receivedUserRadioAfterPlaylistsUpdate:withInfo:)];
}

- (void)receivedUserRadioAfterPlaylistsUpdate:(Radio*)r withInfo:(NSDictionary*)info
{
  [ActivityAlertView close];
  
  if (_wizard)
  {
    SettingsViewController* view = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil wizard:YES radio:[YasoundDataProvider main].radio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];    
  }
  else
    [self.navigationController popViewControllerAnimated:YES];
}


@end
