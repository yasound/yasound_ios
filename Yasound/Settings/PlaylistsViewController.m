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



@implementation PlaylistsViewController

- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil wizard:(BOOL)wizard
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _wizard = wizard;
        _changed = NO;
        
        
        //......................................................................................
        // init playlists
        //
        MPMediaQuery *playlistsquery = [MPMediaQuery playlistsQuery];
        
        _playlistsDesc = [[NSMutableArray alloc] init];
        [_playlistsDesc retain];
        
        _playlists = [playlistsquery collections];
        [_playlists retain];
        
        for (MPMediaPlaylist* list in _playlists)
        {
            NSString* listname = [list valueForProperty: MPMediaPlaylistPropertyName];
            
            NSMutableDictionary* dico = [[NSMutableDictionary alloc] init];
            [dico setObject:listname forKey:@"name"];
            [dico setObject:[NSNumber numberWithInteger:[list count]] forKey:@"count"];
            [_playlistsDesc addObject:dico];
            
            NSLog (@"playlist : %@", listname);
        }
        
        _selectedPlaylists = [[NSMutableArray alloc] init];
        [_selectedPlaylists retain];
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
        _nextBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Navigation_next", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(onNext:)];
        NSMutableArray* items = [NSMutableArray arrayWithArray:_toolbar.items];
        [items addObject:_nextBtn];
        [_toolbar setItems:items animated:NO];
        
        if (([_playlists count] != 0) || forceEnableNextBtn)
            _nextBtn.enabled = YES;
        else
            _nextBtn.enabled = NO;
    }
    
    
    _cellHowtoLabel.text = NSLocalizedString(@"PlaylistsView_howto", nil);
    
    if ([_playlistsDesc count] == 0)
    {
        [_tableView removeFromSuperview];
        _itunesConnectLabel.text = NSLocalizedString(@"PlaylistsView_empty_message", nil);
        [_container addSubview:_itunesConnectView];
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
    // Return YES for supported orientations
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
    
    if ([_selectedPlaylists containsObject:[_playlists objectAtIndex:indexPath.row]])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d songs", [[dico objectForKey:@"count"] integerValue]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    MPMediaPlaylist* list = [_playlists objectAtIndex:indexPath.row];
    
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
    [[PlaylistMoulinor main] buildDataWithPlaylists:_selectedPlaylists binary:NO compressed:YES target:self action:@selector(didBuildDataWithPlaylist:)];
    
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(onFakeSubmitAction:) userInfo:nil repeats:NO];
}



- (void) didBuildDataWithPlaylist:(NSData*)data
{
    //LBDEBUG email playlist file
//      [[PlaylistMoulinor main] emailData:data to:@"neywen@neywen.net" mimetype:@"application/octet-stream" filename:@"yasound_playlist.bin" controller:self];

  Radio* radio = [[Radio alloc] init];
  radio.id = [NSNumber numberWithInt:1];
  [[YasoundDataProvider main] updatePlaylists:data forRadio:radio target:self action:@selector(receiveUpdatePLaylistsResponse:error:)];
    
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(onFakeSubmitAction:) userInfo:nil repeats:NO];
}


- (void)receiveUpdatePLaylistsResponse:(taskID)task_id error:(NSError*)error
{
  if (error)
    NSLog(@"update playlists error %d", error.code);
  else
    NSLog(@"playlists updated  task: %@", task_id);
}


//LBDEBUG
- (void)onFakeSubmitAction:(NSTimer*)timer
{
    [ActivityAlertView close];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationPushRadio" object:nil];
}


@end
