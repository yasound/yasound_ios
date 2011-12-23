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

@implementation PlaylistsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.title = NSLocalizedString(@"PlaylistsView_title", nil);
        
        // "next" button
        _nextBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SettingsView_navigation_next", nil) style:UIBarButtonItemStylePlain target:self action:@selector(onNext:)];
        self.navigationItem.rightBarButtonItem = _nextBtn;
        
        [_nextBtn setEnabled:NO];
        
        
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
    
    _cellHowtoLabel.text = NSLocalizedString(@"PlaylistsView_howto", nil);
    
    if ([_playlistsDesc count] == 0)
    {
        _itunesConnectLabel.text = NSLocalizedString(@"PlaylistsView_empty_message", nil);
        [self.view addSubview:_itunesConnectView];
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
}







#pragma mark - IBActions

- (void)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onNext:(id)sender
{
    //fake commnunication
    [ActivityAlertView showWithTitle:NSLocalizedString(@"msg_submit_title", nil) message:NSLocalizedString(@"msg_submit_body", nil)];

    [[NSUserDefaults standardUserDefaults] synchronize];
    //    
       [[PlaylistMoulinor main] buildDataWithPlaylists:_selectedPlaylists binary:NO compressed:NO target:self action:@selector(didBuildDataWithPlaylist:)];

    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(onFakeSubmitAction:) userInfo:nil repeats:NO];
}



- (void) didBuildDataWithPlaylist:(NSData*)data
{
    //LBDEBUG email playlist file
      [[PlaylistMoulinor main] emailData:data to:@"neywen@neywen.net" mimetype:@"application/octet-stream" filename:@"yasound_playlist.bin" controller:self];
    
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(onFakeSubmitAction:) userInfo:nil repeats:NO];
}


//LBDEBUG
- (void)onFakeSubmitAction:(NSTimer*)timer
{
    [ActivityAlertView close];
    
//    RadioViewController* view = [[RadioViewController alloc] init];
//    self.navigationController.navigationBarHidden = YES;
//    [self.navigationController pushViewController:view animated:YES];
//    [view release];
}


@end
