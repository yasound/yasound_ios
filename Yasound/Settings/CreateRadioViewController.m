//
//  CreateRadioViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 21/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "CreateRadioViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ActivityAlertView.h"
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
#import "TimeProfile.h"



@implementation CreateRadioViewController

@synthesize radio;
@synthesize topbar;
@synthesize nbMatchedSongs;
@synthesize nbPlaylistsForChecking;
@synthesize nbParsedPlaylistsForChecking;
@synthesize playlistsDataPackage;
@synthesize taskTimer;
@synthesize createMode;


- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.createMode = YES;
        
        _displayMode = eDisplayModeNormal;
        _songsViewController = nil;
        _changed = NO;
        
        _checkmarkImage = [UIImage imageNamed:@"WhiteCheckmark.png"];
        [_checkmarkImage retain];
        _checkmarkDisabledImage = [UIImage imageNamed:@"GrayCheckmark.png"];
        [_checkmarkDisabledImage retain];
    }
    
    return self;
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
    [_checkmarkDisabledImage release];
    if (_songsViewController) {
        [_songsViewController release];
    }
    [_localPlaylistsDesc release];
    [_playlists release];
    [_playlistsDesc release];
    [_selectedPlaylists release];
    [_unselectedPlaylists release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.topbar.actionButton.enabled = NO;
    
    
    //......................................................................................
    // init playlists
    //
    
    
    MPMediaQuery *playlistsquery = [MPMediaQuery playlistsQuery];
    _playlistsDesc = [[NSMutableArray alloc] init];
    [_playlistsDesc retain];
    _playlists = [playlistsquery collections];
    [_playlists retain];
    
    
    [self.view addSubview:_tableView];
    
    _selectedPlaylists = [[NSMutableArray alloc] init];
    [_selectedPlaylists retain];
    
    _unselectedPlaylists = [[NSMutableArray alloc] init];
    [_unselectedPlaylists retain];
    
    _localPlaylistsDesc = [[NSMutableArray alloc] init];
    [_localPlaylistsDesc retain];
}


- (void)viewDidAppear:(BOOL)animated
{
//    [ActivityAlertView showWithTitle: NSLocalizedString(@"PlaylistsViewController_FetchingPlaylists", nil)];
    
    // build global songs catalog
    MPMediaQuery* query = [MPMediaQuery songsQuery];
    _songs = [query items];
    [_songs retain];
    
    [self buildPlaylistData:_playlists];

    
    // refresh
    [self refreshView];
    
//    [ActivityAlertView close];
    
    if (_songs.count == 0)
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Programming.empty" retainStylesheet:YES overwriteStylesheet:YES error:nil];
        UIImageView* view = [sheet makeImage];
        [_tableView addSubview:view];
        [view release];
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Programming.Catalog.local", nil) message:NSLocalizedString(@"Programming.empty", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];
        return;
    }
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MyRadios.create", nil) message:NSLocalizedString(@"MyRadios.create.howto", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];

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

- (void)buildPlaylistData:(NSArray *)localPlaylists
{
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

            if (mediaPlaylist)
                [_selectedPlaylists addObject:dico];
    }
}






                                                                                      




-(void)refreshView
{
    if (([_playlistsDesc count] == 0) && (_songs.count == 0))
    {
        [_tableView removeFromSuperview];
        _itunesConnectLabel.text = NSLocalizedString(@"PlaylistsView_empty_message", nil);
        [_container addSubview:_itunesConnectView];
        
        self.topbar.actionButton.enabled = NO;

    }
    else 
    {
        [_tableView reloadData];
        
        self.topbar.actionButton.enabled = YES;

    }
}







#pragma mark - TableView Source and Delegate



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == 1)
    {
        NSInteger nbRows = [_localPlaylistsDesc count];
        return nbRows;
    }
    
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22;
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

    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 26)];
    view.backgroundColor = [UIColor clearColor];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.viewForHeader" retainStylesheet:YES overwriteStylesheet:YES error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = title;
    [view addSubview:label];
    
    return view;
}




- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger nbRows;
    if (indexPath.section == 1)
    {
        nbRows = [_localPlaylistsDesc count];
    }
    
    if ((nbRows == 1) || ((indexPath.section == 0) && (indexPath.row == 0)))
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
    if ((indexPath.section == 0) && (indexPath.row == 0))
    {
        static NSString* CellIdentifier = @"CellSelect";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        _switchAllMyMusic = nil;
        
        if (cell == nil) 
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            _switchAllMyMusic = [[UISwitch alloc] init];
            _switchAllMyMusic.frame = CGRectMake(cell.frame.size.width - _switchAllMyMusic.frame.size.width - 2*8, 8, _switchAllMyMusic.frame.size.width, _switchAllMyMusic.frame.size.height);
            [cell addSubview:_switchAllMyMusic];

            
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
            
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.textColor = [UIColor grayColor];
            
            _switchAllMyMusic.on = YES;
            [_switchAllMyMusic addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
            
        }
        else
        {
            for (id child in cell.subviews)
            {
                if ([child isKindOfClass:[UISwitch class]])
                {
                    _switchAllMyMusic = child;
                    break;
                }
            }
            
            assert(_switchAllMyMusic != nil);
        }

        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        
        cell.textLabel.text = NSLocalizedString(@"PlaylistsView_allMusic", nil);
        
        NSString* detail = NSLocalizedString(@"PlaylistsView_allMusic_detail", nil);
        detail = [detail stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", _songs.count]];
        cell.detailTextLabel.text = detail;
        

        return cell;
    }
    
    
    
    NSMutableArray *source = nil;
    
    if (indexPath.section == 1) 
        source = _localPlaylistsDesc;
    
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // DISABLE THE CELL IF "ALL MY MUSIC" IS CHECKED
    if (_switchAllMyMusic.on)
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    else
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    NSDictionary* dico = [source objectAtIndex:indexPath.row];
  
    BOOL neverSynchronized = [(NSNumber *)[dico objectForKey:@"neverSynchronized"] boolValue];
    cell.textLabel.text = [dico objectForKey:@"name"];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    if (_switchAllMyMusic.on)
        cell.textLabel.textColor = [UIColor grayColor];
    else
        cell.textLabel.textColor = [UIColor blackColor];
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    
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
        _songsViewController = [[SongsViewController alloc] initWithNibName:@"SongsViewController" bundle:nil playlistId:[playlistId integerValue] forRadio:self.radio];
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
    
}



- (void)checkmark:(UITableViewCell*)cell with:(BOOL)value
{
    if (value)
    {
        UIImageView *checkmark = nil;
        if (!_switchAllMyMusic.on)
            checkmark = [[UIImageView alloc] initWithImage:_checkmarkImage];
        else
            checkmark = [[UIImageView alloc] initWithImage:_checkmarkDisabledImage];
        
        cell.accessoryView = checkmark;
        [checkmark release];
        return;
    }
    
    cell.accessoryView = nil;
}



#pragma mark - IBActions


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
    [ActivityAlertView showWithTitle:nil];
    
    [[YasoundDataProvider main] createRadioWithTarget:self action:@selector(onRadioCreated:success:)];
}


- (void)onRadioCreated:(ASIHTTPRequest*)req success:(BOOL)success
{
    if (!success)
    {
        [ActivityAlertView close];
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Playlists.create.failed.title", nil) message:NSLocalizedString(@"Playlists.create.failed.message", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
  
        return;
    }
    
    [ActivityAlertView close];
    
    self.radio = [req responseObjectWithClass:[Radio class]];
    
    //LBDEBUG
    DLog(@"radio created : %p", self.radio);
    DLog(@"radio name : %@", self.radio.name);

    //fake commnunication
    [ActivityAlertView showWithTitle:NSLocalizedString(@"PlaylistsView_submit_title", nil) message:@"..."];
    
    if (_switchAllMyMusic.on)
    {
        [[PlaylistMoulinor main] buildDataWithSongs:_songs
                                                 binary:YES 
                                             compressed:YES 
                                                 target:self 
                                                 action:@selector(didBuildDataWithPlaylist:)];
    }
    else
    {
        [[PlaylistMoulinor main] buildDataWithPlaylists:_selectedPlaylists
                                       removedPlaylists:_unselectedPlaylists
                                                 binary:YES 
                                             compressed:YES 
                                                 target:self 
                                                 action:@selector(didBuildDataWithPlaylist:)];
    }
}



- (void) didBuildDataWithPlaylist:(NSData*)data
{
    //LBDEBUG email playlist file
//      [[PlaylistMoulinor main] emailData:data to:@"neywen@neywen.net" mimetype:@"application/octet-stream" filename:@"yasound_playlist.bin" controller:self];
//    [ActivityAlertView close];
//    return;

    DLog(@"Playlists data package has been built.");
    
    
        DLog(@"For radio %@", self.radio.name);
        [[YasoundDataProvider main] updatePlaylists:data forRadio:self.radio target:self action:@selector(receiveUpdatePLaylistsResponse:error:)];
}
    



#pragma mark - UIAlertViewDelegate
    
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _alertMatchedSongs)
    {
        [self getOut];
        return;
    }
}

    
    
    


- (void)receiveUpdatePLaylistsResponse:(taskID)task_id error:(NSError*)error
{
  if (error)
  {
      DLog(@"update playlists error %d", error.code);
      DLog(@"%@", error);
      
      [ActivityAlertView close];
      
      UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PlaylistsView_submit_title", nil) message:NSLocalizedString(@"PlaylistsView_submit_error_creating_radio", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [av show];
      [av release];  

      
      return;
  }
    
    DLog(@"playlists updated  task: %@", task_id);
    
    self.taskTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkPlaylistTask:) userInfo:task_id repeats:YES];
    
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
        if ([self.taskTimer isValid])
            [self.taskTimer invalidate];
        [self finalize];
    }
    else if (taskInfo.status == eTaskFailure)
    {
        [self finalize];
    }
  else if (taskInfo.status == eTaskPending)
  {
    NSString* msg = [NSString stringWithFormat:@"%d%%", (int)(taskInfo.progress * 100)];
    if (taskInfo.message)
      msg = [msg stringByAppendingFormat:@" - %@", taskInfo.message];
    [ActivityAlertView current].message = msg;
  }
}













- (void)finalize
{
    // be sure to get updated radio (with correct 'ready' flag)
   // [[YasoundDataProvider main] userRadioWithTarget:self action:@selector(receivedUserRadioAfterPlaylistsUpdate:withInfo:)];
    [[YasoundDataProvider main] radioWithId:self.radio.id target:self action:@selector(receivedUserRadioAfterPlaylistsUpdate:withInfo:)];
}

- (void)receivedUserRadioAfterPlaylistsUpdate:(Radio*)r withInfo:(NSDictionary*)info
{
    assert(r != nil);
    self.radio = r;
    
    // now, ask for registered playlists, we want to check how many songs have been synchrpnized
    [[YasoundDataProvider main] playlistsForRadio:r target:self action:@selector(receivePlaylistsForChecking:withInfo:)];
}
    
    
- (void)receivePlaylistsForChecking:(NSArray*)playlists withInfo:(NSDictionary*)info
{
    self.nbPlaylistsForChecking = playlists.count;
    self.nbParsedPlaylistsForChecking = 0;
    self.nbMatchedSongs = 0;
    
    
    for (Playlist* playlist in playlists) 
    {
        [[YasoundDataProvider main] matchedSongsForPlaylist:playlist target:self action:@selector(matchedSongsReceveived:info:)]; 
    }
}
    
    
- (void)matchedSongsReceveived:(NSArray*)songs info:(NSDictionary*)info
{
    self.nbParsedPlaylistsForChecking++;
    
    if (songs != nil)
        self.nbMatchedSongs += songs.count;
    
    if (nbParsedPlaylistsForChecking != nbPlaylistsForChecking)
        return;

    // now we have the right count of the synchronized songs
    [ActivityAlertView close];

    // user dialog to report 
    NSString* title = nil;
    NSString* message = nil;
    
    if (self.nbMatchedSongs == 0)
    {
        title = NSLocalizedString(@"PlaylistsView_matchedSongsTitle_zero", nil);
        message = NSLocalizedString(@"PlaylistsView_matchedSongsMessage_zero", nil);
    }
    else
    {
        title = NSLocalizedString(@"PlaylistsView_matchedSongsTitle_ok", nil);
        
        if (self.nbMatchedSongs == 1)
            message = NSLocalizedString(@"PlaylistsView_matchedSongsMessage_ok_1", nil);
        else
            message = NSLocalizedString(@"PlaylistsView_matchedSongsMessage_ok_n", nil);
        
        message = [message stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", self.nbMatchedSongs]];

    }

    _alertMatchedSongs = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [_alertMatchedSongs show];
    [_alertMatchedSongs release];  
}
    


- (void)onSwitch:(id)sender
{
    [self refreshView];
}





- (void)getOut
{
    SettingsViewController* view = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil forRadio:self.radio createMode:YES];
    [self.navigationController pushViewController:view animated:YES];
    [view release];    
}



#pragma mark - TopBarSaveOrCancel

- (NSString*)titleForActionButton
{
    return NSLocalizedString(@"Navigation.create", nil);
}


- (BOOL)topBarSave
{
    [self save];
    return NO;
}




@end
