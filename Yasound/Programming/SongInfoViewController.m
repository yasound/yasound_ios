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



@implementation SongInfoViewController


@synthesize song;

#define NB_SECTIONS 2

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
    
    return 44;
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
                NSURL* url = [[YasoundDataProvider main] urlForSongCover:self.song];
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
             _imageView.frame = CGRectMake(2*BORDER, (height - size) / 2.f, size, size);
            
            [cell addSubview:_imageView];
            
            // name, artist, album
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"SongView_name" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            _name = [sheet makeLabel];
            [cell addSubview:_name];
            
            sheet = [[Theme theme] stylesheetForKey:@"SongView_artist" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            _artist = [sheet makeLabel];
            [cell addSubview:_artist];
            
            sheet = [[Theme theme] stylesheetForKey:@"SongView_album" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            _album = [sheet makeLabel];
            [cell addSubview:_album];

            
            sheet = [[Theme theme] stylesheetForKey:@"SongView_nbLikes" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            UILabel* label = [sheet makeLabel];
            label.text = NSLocalizedString(@"SongView_nbLikes", nil);
            [cell addSubview:label];

            sheet = [[Theme theme] stylesheetForKey:@"SongView_nbLikes_value" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            label = [sheet makeLabel];
            label.text = [NSString stringWithFormat:@"%@", self.song.likes];
            [cell addSubview:label];

            
            
            
            sheet = [[Theme theme] stylesheetForKey:@"SongView_lastRead" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            label = [sheet makeLabel];
            label.text = NSLocalizedString(@"SongView_lastRead", nil);
            [cell addSubview:label];
            
            sheet = [[Theme theme] stylesheetForKey:@"SongView_lastRead_value" retainStylesheet:YES overwriteStylesheet:NO error:nil];
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
    
    
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
        if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_ENABLE))
        {
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"SongView_enable_switch" retainStylesheet:YES overwriteStylesheet:NO error:nil];
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
        cell.textLabel.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
    }

    
    //
    // update
    //
    if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_ENABLE))
    {
        //sheet = [[Theme theme] stylesheetForKey:@"SongView_enable_label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
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


    
    
    return cell;
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




@end
