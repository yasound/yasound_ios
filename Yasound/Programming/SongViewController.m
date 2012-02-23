//
//  SongViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongViewController.h"
#import "WebImageView.h"
#import "YasoundDataProvider.h"
#import "BundleFileManager.h"
#import "Theme.h"

#define NB_ROWS 7
#define ROW_COVER 0
#define ROW_NAME 1
#define ROW_ARTIST 2
#define ROW_ALBUM 3
#define ROW_NBLIKES 4
#define ROW_LAST_READ 5
#define ROW_FREQUENCY 6


@implementation SongViewController


@synthesize song;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil song:(Song*)song
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.song = song;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _titleLabel.text = NSLocalizedString(@"SongView_title", nil);
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);

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
        return 148;
    
    return 44;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.row == ROW_COVER)
    {
        UIView* view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
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
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];

        WebImageView* imageView = nil;
        if (self.song.cover)
        {        
            NSURL* url = [[YasoundDataProvider main] urlForPicture:self.song.cover];
            imageView = [[WebImageView alloc] initWithImageAtURL:url];
        }
        else
        {
            // fake image
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarImageDummy" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            imageView = [[UIImageView alloc] initWithImage:[sheet image]];
        }
        
        CGFloat size = 128;
        CGFloat height = 148;
        imageView.frame = CGRectMake((cell.frame.size.width - size) / 2.f, (height - size) / 2.f, size, size);
        
        [cell addSubview:imageView];
        return cell;
        
    }

    
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (indexPath.row == ROW_NAME)
    {
        cell.textLabel.text = NSLocalizedString(@"SongView_name", nil);
        cell.detailTextLabel.text = self.song.name;
    }
    else if (indexPath.row == ROW_ARTIST)
    {
        cell.textLabel.text = NSLocalizedString(@"SongView_artist", nil);
        cell.detailTextLabel.text = self.song.artist;
    }
    else if (indexPath.row == ROW_ALBUM)
    {
        cell.textLabel.text = NSLocalizedString(@"SongView_album", nil);
        cell.detailTextLabel.text = self.song.album;
    }
    else if (indexPath.row == ROW_NBLIKES)
    {
        cell.textLabel.text = NSLocalizedString(@"SongView_nbLikes", nil);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.song.likes];
    }
    else if (indexPath.row == ROW_LAST_READ)
    {
        cell.textLabel.text = NSLocalizedString(@"SongView_lastRead", nil);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.song.last_play_time];
    }
    else if (indexPath.row == ROW_FREQUENCY)
    {
        cell.textLabel.text = NSLocalizedString(@"SongView_frequency", nil);
        
        NSString* frequencyStr = nil;
        
        if (self.song.frequency == eSongFrequencyTypeNormal)
            frequencyStr = NSLocalizedString(@"SongView_frequency_normal", nil);
        else if (self.song.frequency == eSongFrequencyTypeHigh)
            frequencyStr = NSLocalizedString(@"SongView_frequency_high", nil);
        else 
            frequencyStr = NSLocalizedString(@"SongView_frequency_none", nil);

        cell.detailTextLabel.text = frequencyStr;
    }


    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}













#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
