//
//  SongPublicInfoViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 29/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongPublicInfoViewController.h"
#import "YasoundDataProvider.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "AudioStreamManager.h"
#import "RootViewController.h"
#import "ActivityAlertView.h"
#import "SongCatalog.h"
#import "YasoundReachability.h"
#import "SongUploadManager.h"
#import "SongUploadViewController.h"


@implementation SongPublicInfoViewController


@synthesize song;

#define NB_SECTIONS 1

#define SECTION_COVER 0


#define BORDER 8
#define COVER_SIZE 320




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
    
    if (!_showNowPlaying)
    {
        [_toolbar setItems:[NSArray arrayWithObjects:_backBtn, nil]];
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
    return 1;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return 416;
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
    UIView* view = [[UIView alloc] init];
    view.backgroundColor = [UIColor blackColor];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    cell.backgroundView = view;
    
    [view release];
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
      
            
//            if (song.cover)
//            {        
//                NSURL* url = [[YasoundDataProvider main] urlForPicture:song.cover];
//                _webImageView = [[WebImageView alloc] initWithImageAtURL:url];
//                imageView = _webImageView;
//            }
//            else
//            {
//                // fake image
//                sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarImageDummy" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//                imageView = [[UIImageView alloc] initWithImage:[sheet image]];
//            }
//
//            
            cell.backgroundColor = [UIColor blackColor];
            
            
            if (self.song.cover)
            {
                NSURL* url = [[YasoundDataProvider main] urlForPicture:self.song.cover];
                _imageView = [[WebImageView alloc] initWithImageAtURL:url];
            }
            else
            {
                // fake image
                BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarImageDummy" retainStylesheet:YES overwriteStylesheet:NO error:nil];
                _imageView = [[WebImageView alloc] initWithImage:[sheet image]];
            }
            
            CGFloat size = COVER_SIZE;
            CGFloat height = (COVER_SIZE + 2*BORDER);
             _imageView.frame = CGRectMake(cell.frame.size.width/2.f - size/2.f, 0 , size, size);
            
            [cell addSubview:_imageView];
            
            // name, artist, album
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"SongPublicView_name" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            _name = [sheet makeLabel];
            [cell addSubview:_name];
            
            sheet = [[Theme theme] stylesheetForKey:@"SongPublicView_artist" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            _artist = [sheet makeLabel];
            [cell addSubview:_artist];
            
            sheet = [[Theme theme] stylesheetForKey:@"SongPublicView_album" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            _album = [sheet makeLabel];
            [cell addSubview:_album];


            NSString* laststr = nil;
            if (self.song.last_play_time != nil)
                laststr = [NSString stringWithFormat:@"%@", [self dateToString:self.song.last_play_time]];
            else
                laststr = @"-";

            sheet = [[Theme theme] stylesheetForKey:@"SongPublicView_lastRead" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            UILabel* label = [sheet makeLabel];
            label.text = [NSString stringWithFormat:@"%@ : %@", NSLocalizedString(@"SongView_lastRead", nil), laststr];
            [cell addSubview:label];
            
            [cell addSubview:label];

            
            sheet = [[Theme theme] stylesheetForKey:@"SongPublicView_nbLikes" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            label = [sheet makeLabel];
            label.text = [NSString stringWithFormat:@"%@ : %@", NSLocalizedString(@"SongView_nbLikes", nil), self.song.likes];
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

    
    
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
    




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

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nowPlayingClicked:(id)sender
{
    // call root to launch the Radio
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:nil]; 
}









@end
