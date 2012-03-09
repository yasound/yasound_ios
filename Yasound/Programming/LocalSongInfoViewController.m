//
//  LocalSongInfoViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 29/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "LocalSongInfoViewController.h"
#import "YasoundDataProvider.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "AudioStreamManager.h"
#import "RootViewController.h"



@implementation LocalSongInfoViewController


@synthesize song;


//@property (nonatomic, retain) NSString* genre;
//@property (nonatomic) NSTimeInterval playbackDuration; 
//@property (nonatomic) NSUInteger albumTrackNumber;
//@property (nonatomic) NSUInteger albumTrackCount;
//@property (nonatomic, retain) MPMediaItemArtwork* artwork;
//@property (nonatomic) NSUInteger rating;


#define NB_ROWS 4
#define ROW_COVER 0
#define ROW_GENRE 1
#define ROW_DURATION 2
#define ROW_RATING 3

#define BORDER 8
#define COVER_SIZE 96




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil song:(SongLocal*)aSong
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

    _titleLabel.text = NSLocalizedString(@"SongAddView_title", nil);
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
        UITableViewCell* cell = nil;
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
        
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];

        cell.selectionStyle  = UITableViewCellSelectionStyleNone;

        _imageView = [[UIImageView alloc] initWithImage:[self.song.artwork imageWithSize:CGSizeMake(COVER_SIZE, COVER_SIZE)]];

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


        _name.text = [NSString stringWithFormat:@"%d. %@", song.albumTrackNumber, song.name];
        _artist.text = song.artist;
        _album.text = song.album;

        return cell;
        
    }
    
    
    
    
    if (indexPath.row == ROW_RATING)
    {
        static NSString* CellIdentifier = @"CellRating";
        UITableViewCell* cell = nil;
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
        

        cell.textLabel.text = NSLocalizedString(@"SongView_rating", nil);
        
        UIImage* star = [UIImage imageNamed:@"SongRatingStar.png"];
        UIImage* bullet = [UIImage imageNamed:@"SongRatingBullet.png"];
        
        NSInteger i = 0;
        CGRect frame = CGRectMake(180, (cell.frame.size.height - star.size.height) /2.f, star.size.width, star.size.height);
        for (i = 0; i < self.song.rating; i++)
        {
            UIImageView* view = [[UIImageView alloc] initWithImage:star];
            view.frame = frame;
            [cell addSubview:view];
            
            frame = CGRectMake(frame.origin.x + frame.size.width + 8, frame.origin.y, star.size.width, star.size.height);
        }

        frame = CGRectMake(frame.origin.x, (cell.frame.size.height - bullet.size.height) /2.f, bullet.size.width, bullet.size.height);
        for (NSInteger j = i; j < 5; j++)
        {
            UIImageView* view = [[UIImageView alloc] initWithImage:bullet];
            view.frame = frame;
            [cell addSubview:view];
            
            frame = CGRectMake(frame.origin.x + star.size.width + 5, frame.origin.y, bullet.size.width, bullet.size.height);
        }
        
        return cell;
    }


    
    
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    
    if (indexPath.row == ROW_GENRE)
    {
        cell.textLabel.text = NSLocalizedString(@"SongView_genre", nil);
        cell.detailTextLabel.text = self.song.genre;
    }
    else if (indexPath.row == ROW_DURATION)
    {
        cell.textLabel.text = NSLocalizedString(@"SongView_duration", nil);
        
        NSInteger min = self.song.playbackDuration / 60;
        NSInteger sec = ((CGFloat)(self.song.playbackDuration / 60.f) - min) * 100;
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d:%d", min, sec];
    }


    
    
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

- (IBAction)nowPlayingClicked:(id)sender
{
    // call root to launch the Radio
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:nil]; 
}






@end