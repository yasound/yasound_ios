//
//  SongInfoViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 29/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongInfoViewController.h"
#import "YasoundDataProvider.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "AudioStreamManager.h"
#import "RootViewController.h"
#import "ActivityAlertView.h"
#import "SongCatalog.h"
#import "YasoundReachability.h"
#import "SongUploadManager.h"
#import "ProgrammingUploadViewController.h"


@implementation SongInfoViewController


@synthesize song;

#define NB_SECTIONS 4

#define SECTION_COVER 0

#define SECTION_CONFIG 1
#define ROW_CONFIG_ENABLE 0
#define ROW_CONFIG_HIGHFREQ 1

#define SECTION_REJECT 2

#define SECTION_DELETE 3


#define BORDER 8
#define COVER_SIZE 96




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil song:(Song*)aSong showNowPlaying:(BOOL)showNowPlaying
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.song = aSong;
        _showNowPlaying = showNowPlaying;
        _ownSong = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _titleLabel.text = NSLocalizedString(@"ProgrammingView_title", nil);
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);
    
    _cellDeleteLabel.text = NSLocalizedString(@"SongView_delete", nil);
    
    if (!_showNowPlaying)
    {
        [_toolbar setItems:[NSArray arrayWithObjects:_backBtn, nil]];
    }
    
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
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








- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([AudioStreamManager main].currentRadio == nil)
        [_nowPlayingButton setEnabled:NO];
    else
        [_nowPlayingButton setEnabled:YES];
    
}




#pragma mark - TableView Source and Delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //    return gIndexMap.count;
    return NB_SECTIONS;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == SECTION_CONFIG)
        return 2;
    return 1;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (indexPath.section == SECTION_COVER)
        return (COVER_SIZE + 2*BORDER);
    
    return 46;
}


- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.section == SECTION_COVER)
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellSongCardRow.png"]];
        cell.backgroundView = view;
        [view release];
        return;
    }

    if (indexPath.section == SECTION_DELETE)
    {
        UIView* view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        cell.backgroundView = view;
        [view release];
        return;
    }
    
    
    NSInteger nbRows;
    if (indexPath.section == SECTION_CONFIG)
        nbRows =  2;
    
    else 
        nbRows =  1;
    
    
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
    if (indexPath.section == SECTION_COVER)
    {
        static NSString* CellIdentifier = @"SongInfoCellCover";
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) 
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
            cell.selectionStyle  = UITableViewCellSelectionStyleNone;
      
            if (self.song.cover)
            {
                NSURL* url = [[YasoundDataProvider main] urlForPicture:self.song.cover];
                _imageView = [[WebImageView alloc] initWithImageAtURL:url];
            }
            else
            {
                // fake image
                BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Wall.NowPlaying.Wall.NowPlaying.NowPlayingBarImageDummy" retainStylesheet:YES overwriteStylesheet:NO error:nil];
                _imageView = [[WebImageView alloc] initWithImage:[sheet image]];
            }
            
            CGFloat size = COVER_SIZE;
            CGFloat height = (COVER_SIZE + 2*BORDER);
             _imageView.frame = CGRectMake(2*BORDER, (height - size) / 2.f, size, size);
            
            [cell addSubview:_imageView];
            
            // name, artist, album
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"SongView.SongView_name" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            _name = [sheet makeLabel];
            [cell addSubview:_name];
            
            sheet = [[Theme theme] stylesheetForKey:@"SongView.SongView_artist" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            _artist = [sheet makeLabel];
            [cell addSubview:_artist];
            
            sheet = [[Theme theme] stylesheetForKey:@"SongView.SongView_album" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            _album = [sheet makeLabel];
            [cell addSubview:_album];

            
            sheet = [[Theme theme] stylesheetForKey:@"SongView.SongView_nbLikes" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            UILabel* label = [sheet makeLabel];
            label.text = NSLocalizedString(@"SongView_nbLikes", nil);
            [cell addSubview:label];

            sheet = [[Theme theme] stylesheetForKey:@"SongView.SongView_nbLikes_value" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            label = [sheet makeLabel];
            label.text = [NSString stringWithFormat:@"%@", self.song.likes];
            [cell addSubview:label];

            
            
            
            sheet = [[Theme theme] stylesheetForKey:@"SongView.SongView_lastRead" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            label = [sheet makeLabel];
            label.text = NSLocalizedString(@"SongView_lastRead", nil);
            [cell addSubview:label];
            
            sheet = [[Theme theme] stylesheetForKey:@"SongView.SongView_lastRead_value" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            label = [sheet makeLabel];
            if (self.song.last_play_time != nil)
                label.text = [NSString stringWithFormat:@"%@", [self dateToString:self.song.last_play_time]];
            else
                label.text = @"-";
            [cell addSubview:label];
        }
        
        else
        {
          NSURL* url = [[YasoundDataProvider main] urlForSongCover:self.song];
          [_imageView setUrl:url];
        }
        
        _name.text = song.name;
        _artist.text = song.artist;
        _album.text = song.album;

        
        return cell;
        
    }
    else if (indexPath.section == SECTION_DELETE)
    {
        return _cellDelete;
    }

    
    
    
    
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
        if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_ENABLE))
        {
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"SongView.SongView_enable_switch" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            _switchEnabled = [[UISwitch alloc] init];
            _switchEnabled.frame = CGRectMake(sheet.frame.origin.x, sheet.frame.origin.y, _switchEnabled.frame.size.width, _switchEnabled.frame.size.height);
            [cell addSubview:_switchEnabled];

        }
        
        else if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_HIGHFREQ))
        {
            NSString* frequencyStr = nil;
            
            _switchFrequency = [[UISwitch alloc] init];
            _switchFrequency.frame = CGRectMake(cell.frame.size.width - _switchFrequency.frame.size.width - 2*BORDER, (cell.frame.size.height - _switchFrequency.frame.size.height) / 2.f, _switchFrequency.frame.size.width, _switchFrequency.frame.size.height);
            [cell addSubview:_switchFrequency];
        }
        
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        
    }

    
    //
    // update
    //
    if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_ENABLE))
    {
        //sheet = [[Theme theme] stylesheetForKey:@"SongView.SongView_enable_label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        //_enabledLabel = [sheet makeLabel];
        //[cell addSubview:_enabledLabel];

        
        cell.textLabel.text = NSLocalizedString(@"SongView_enable_label", nil);
        
        _switchEnabled.on = [self.song isSongEnabled];
    
        [_switchEnabled addTarget:self action:@selector(onSwitchEnabled:)  forControlEvents:UIControlEventValueChanged];
    }

    else if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_HIGHFREQ))
    {
        cell.textLabel.text = NSLocalizedString(@"SongView_frequency", nil);

        if ([self.song frequencyType] == eSongFrequencyTypeNormal)
            _switchFrequency.on = NO;
        else if ([self.song frequencyType] == eSongFrequencyTypeHigh)
            _switchFrequency.on = YES;
        else 
        {
            _switchFrequency.on = NO;
            _switchFrequency.enabled = NO;
        }
        
        [_switchFrequency addTarget:self action:@selector(onSwitchFrequency:)  forControlEvents:UIControlEventValueChanged];
    }
    
    else if (indexPath.section == SECTION_REJECT)
    {
        cell.textLabel.text = NSLocalizedString(@"SongView_reject", nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;

    }

    

    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != SECTION_REJECT)
        return;
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    // first, check if the user has the targeted song in his local catalog
    _ownSong = [[SongCatalog availableCatalog]doesDeviceContainSong:self.song];
    
    if (_ownSong)
    {
        _alertReject = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SongView_reject_title", nil)
                                                    message:NSLocalizedString(@"SongView_reject_message_own_song_yes", nil) 
                                                   delegate:self 
                                          cancelButtonTitle:NSLocalizedString(@"Navigation_cancel", nil) 
                                          otherButtonTitles:NSLocalizedString(@"SongView_reject_button_own_song_yes", nil), nil];
    }
    else
    {
        _alertReject = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SongView_reject_title", nil)
                                                  message:NSLocalizedString(@"SongView_reject_message_own_song_no", nil) 
                                                 delegate:self 
                                        cancelButtonTitle:NSLocalizedString(@"Navigation_cancel", nil) 
                                        otherButtonTitles:NSLocalizedString(@"SongView_reject_button_own_song_no", nil), nil];    
    }
    
    [_alertReject show];
    [_alertReject release];
}
    




- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DLog(@"alertView didDismissWithButtonIndex %d", buttonIndex);
    
    if ((alertView == _alertReject) && (buttonIndex == 1))
    {
        [ActivityAlertView showWithTitle:nil closeAfterTimeInterval:60];
        
        [[YasoundDataProvider main] rejectSong:self.song target:self action:@selector(didRejectSong:succeeded:)];
        
        return;
    }
    
    if (alertView == _alertUploading)
    {    
        if (buttonIndex == 1)
        {
            // call root to launch the Radio
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_POP_AND_GOTO_UPLOADS object:nil]; 

            //LBDEBUG
//            UINavigationController* navCont = self.navigationController;
//
//            UIViewController* currentView = self;
//            [currentView retain];
//
//            ProgrammingUploadViewController* newView = [[ProgrammingUploadViewController alloc] initWithNibName:@"ProgrammingUploadViewController" bundle:nil];
//
//            [navCont popViewControllerAnimated:YES];
//            [navCont pushViewController:newView animated:YES];
//
//            [newView release];
//            [currentView release];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];            
        }
        
        return;
    }

}    






         
- (void)didRejectSong:(ASIHTTPRequest*)req succeeded:(NSNumber*)success
{
    BOOL succeeded = NO;
    if (success != nil)
        succeeded = [success boolValue];
    
    if (!succeeded)
    {
        [ActivityAlertView showWithTitle:NSLocalizedString(@"SongView_reject_failed", nil) closeAfterTimeInterval:2];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [ActivityAlertView close];
    
    [self.song removeSong:YES];
    
    if (!_ownSong)
    {
        [ActivityAlertView showWithTitle:NSLocalizedString(@"SongView_delete_confirm_message", nil) closeAfterTimeInterval:2];
        return;
    }
    
    [self requestUpload];
}



- (void)requestUpload
{
    BOOL isWifi = ([YasoundReachability main].networkStatus == ReachableViaWiFi);
    
    
    BOOL startUploadNow = isWifi;
    
    // add an upload job to the queue
    [[SongUploadManager main] addSong:song startUploadNow:startUploadNow];
    
    // and flag the current song as "uploading song"
    song.uploading = YES;
    
    if (!isWifi && ![SongUploadManager main].notified3G)
    {
        [SongUploadManager main].notified3G = YES;
        
        UIAlertView* _wifiWarning = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YasoundUpload_add_WIFI_title", nil) message:NSLocalizedString(@"YasoundUpload_add_WIFI_message", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [_wifiWarning show];
        [_wifiWarning release];  
        return; 
    }
    else
    {
        _alertUploading = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SongView_uploading_title", nil) message:NSLocalizedString(@"SongView_uploading_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Navigation_No", nil) otherButtonTitles:NSLocalizedString(@"Navigation_Yes", nil),nil ];
        [_alertUploading show];
        [_alertUploading release];  
    }
    
}


         

//- (void)onRejectNotified:(NSDictionary*)info
//{
//    BOOL succeeded = NO;
//    
//    NSNumber* nb = [info objectForKey:@"succeeded"];
//    if (nb != nil)
//        succeeded = [nb boolValue];
//
//    [ActivityAlertView close];
//    
//    if (!succeeded)
//        return;
//    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SongView_reject_title", nil)
//                                                    message:NSLocalizedString(@"SongView_reject_message", nil) 
//                                                   delegate:self 
//                                          cancelButtonTitle:nil 
//                                          otherButtonTitles:NSLocalizedString(@"RateApp_button_rate", nil), NSLocalizedString(@"RateApp_button_later", nil), NSLocalizedString(@"RateApp_button_no", nil), nil];
//    alert.delegate = self;
//    [alert show];
//    [alert release];
//}












- (NSString*) dateToString:(NSDate*)d
{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    //  [dateFormat setDateFormat:@"HH:mm"];
    NSDate* now = [NSDate date];
    NSDateComponents* todayComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:now];
    NSDateComponents* refComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:d];
    
    if (todayComponents.year == refComponents.year && todayComponents.month == refComponents.month && todayComponents.day == refComponents.day)
    {
        // today: show time
        [dateFormat setDateFormat:@"dd/MM, HH:mm"];
    }
    else
    {
        // not today: show date
        [dateFormat setDateFormat:@"dd/MM, HH:mm"];
    }
    
    NSString* s = [dateFormat stringFromDate:d];
    [dateFormat release];
    return s;
}











#pragma mark - IBActions

- (void)onSwitchEnabled:(id)sender
{
    BOOL enabled = _switchEnabled.on;
    
    [self.song enableSong:enabled];
    
    [[YasoundDataProvider main] updateSong:self.song target:self action:@selector(onSongUpdated:info:)];
}


- (void)onSwitchFrequency:(id)sender
{
  BOOL highFreq = _switchFrequency.on;
  SongFrequencyType freq = highFreq ? eSongFrequencyTypeHigh : eSongFrequencyTypeNormal;
  [self.song setFrequencyType:freq];
  
  [[YasoundDataProvider main] updateSong:self.song target:self action:@selector(onSongUpdated:info:)];
}


- (void)onSongUpdated:(Song*)song info:(NSDictionary*)info
{
    self.song = song;
    [_tableView reloadData];
}





- (IBAction)onDeleteSong:(id)sender
{
    DLog(@"onDeleteSong");   
    
    [ActivityAlertView showWithTitle:nil];

    // request to server
    [[YasoundDataProvider main] deleteSong:self.song target:self action:@selector(onSongDeleted:info:) userData:nil];
}


// server's callback
- (void)onSongDeleted:(Song*)song info:(NSDictionary*)info
{
    DLog(@"onSongDeleted for Song %@", song.name);  
    DLog(@"info %@", info);
    
    BOOL success = NO;
    NSNumber* nbsuccess = [info objectForKey:@"success"];
    if (nbsuccess != nil)
        success = [nbsuccess boolValue];
    
    DLog(@"success %d", success);
    
    if (!success)
    {
        [ActivityAlertView showWithTitle:NSLocalizedString(@"SongView_delete_failed", nil) closeAfterTimeInterval:2];
        return;
    }
    
    [self.song removeSong:YES];
    
    [[SongCatalog synchronizedCatalog] removeSynchronizedSong:self.song];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PROGAMMING_SONG_REMOVED object:nil];
    
    [ActivityAlertView showWithTitle:NSLocalizedString(@"SongView_delete_confirm_message", nil) closeAfterTimeInterval:2];
    
    [self.navigationController popViewControllerAnimated:YES];
}




@end
