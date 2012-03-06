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


#define NB_ROWS 4
#define ROW_COVER 0
#define ROW_NBLIKES 1
#define ROW_LAST_READ 2
#define ROW_FREQUENCY 3

#define BORDER 8
#define COVER_SIZE 96




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil song:(Song*)aSong
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.song = aSong;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _titleLabel.text = NSLocalizedString(@"ProgrammingView_title", nil);
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);
    
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
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return NB_ROWS;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (indexPath.row == ROW_COVER)
        return (COVER_SIZE + 2*BORDER);
    
    return 44;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.row == ROW_COVER)
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellPlainSongCardRow.png"]];
        cell.backgroundView = view;
        [view release];
        return;
    }
    
    UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellPlainRow.png"]];
    cell.backgroundView = view;
    [view release];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.row == ROW_COVER)
    {
        static NSString* CellIdentifier = @"CellCover";
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) 
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
            cell.selectionStyle  = UITableViewCellSelectionStyleNone;
        
        
            // image cover
            if (self.song.cover)
            {        
                NSURL* url = [[YasoundDataProvider main] urlForPicture:self.song.cover];
                _imageView = [[WebImageView alloc] initWithImageAtURL:url];
            }
            else
            {
                // fake image
                BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarImageDummy" retainStylesheet:YES overwriteStylesheet:NO error:nil];
                 _imageView = [[UIImageView alloc] initWithImage:[sheet image]];
            }
            
            CGFloat size = COVER_SIZE;
            CGFloat height = (COVER_SIZE + 2*BORDER);
             _imageView.frame = CGRectMake(BORDER, (height - size) / 2.f, size, size);
            
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
            
            // enable/disable
            sheet = [[Theme theme] stylesheetForKey:@"SongView_enable_label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            _enabledLabel = [sheet makeLabel];
            [cell addSubview:_enabledLabel];
            
            sheet = [[Theme theme] stylesheetForKey:@"SongView_enable_switch" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            _switchEnabled = [[UISwitch alloc] init];
            _switchEnabled.frame = CGRectMake(sheet.frame.origin.x, sheet.frame.origin.y, _switchEnabled.frame.size.width, _switchEnabled.frame.size.height);
            [cell addSubview:_switchEnabled];
            
        }
        
        else
        {
            // image cover
            if (self.song.cover)
            {        
                NSURL* url = [[YasoundDataProvider main] urlForPicture:self.song.cover];
                [_imageView setUrl:url];
            }
            else
            {
                // fake image
                BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarImageDummy" retainStylesheet:YES overwriteStylesheet:NO error:nil];
                [_imageView setImage:[sheet image]];
            }

        }
        
        
        _name.text = song.name;
        _artist.text = song.artist;
        _album.text = song.album;
        _enabledLabel.text = NSLocalizedString(@"SongView_enable_label", nil);

        _switchEnabled.on = [self.song isSongEnabled];
        [_switchEnabled addTarget:self action:@selector(onSwitchEnabled:)  forControlEvents:UIControlEventValueChanged];

        
        return cell;
        
    }
    
    
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
        if (indexPath.row == ROW_FREQUENCY)
        {
            NSString* frequencyStr = nil;
            
            _switchFrequency = [[UISwitch alloc] init];
            _switchFrequency.frame = CGRectMake(cell.frame.size.width - _switchFrequency.frame.size.width - BORDER, (cell.frame.size.height - _switchFrequency.frame.size.height) / 2.f, _switchFrequency.frame.size.width, _switchFrequency.frame.size.height);
            [cell addSubview:_switchFrequency];
        }
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    
    if (indexPath.row == ROW_NBLIKES)
    {
        cell.textLabel.text = NSLocalizedString(@"SongView_nbLikes", nil);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.song.likes];
    }
    else if (indexPath.row == ROW_LAST_READ)
    {
        cell.textLabel.text = NSLocalizedString(@"SongView_lastRead", nil);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self dateToString:self.song.last_play_time]];
    }
    else if (indexPath.row == ROW_FREQUENCY)
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
