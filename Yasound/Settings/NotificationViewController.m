//
//  NotificationViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 05/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationManager.h"

@interface NotificationViewController ()

@end

@implementation NotificationViewController










- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _titleItem.title = NSLocalizedString(@"SettingsView_title", nil);
    _backItem.title = NSLocalizedString(@"Navigation_back", nil);
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    
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



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [NotificationViewController Notifications].count;
}





- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSInteger nbRows = [NotificationViewController Notifications].count;
    
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
    static NSString* CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    [NotificationViewController Notifications]

    
        
        _switchAllMyMusic = nil;
        
        if (cell == nil) 
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            _switchAllMyMusic = [[UISwitch alloc] init];
            _switchAllMyMusic.frame = CGRectMake(cell.frame.size.width - _switchAllMyMusic.frame.size.width - 2*8, 8, _switchAllMyMusic.frame.size.width, _switchAllMyMusic.frame.size.height);
            [cell addSubview:_switchAllMyMusic];
            
            
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            
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

















- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
