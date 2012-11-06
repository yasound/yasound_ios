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
    return YES;
}








- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
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
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.cell" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    cell.backgroundView = [sheet makeImage];
}








- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.row == ROW_COVER)
    {
        static NSString* CellIdentifier = @"LocalSongInfoCellCover";
        UITableViewCell* cell = nil;
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
        
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];

        cell.selectionStyle  = UITableViewCellSelectionStyleNone;

        
        UIImage* coverImage = [self.song.artwork imageWithSize:CGSizeMake(COVER_SIZE, COVER_SIZE)];
        if (coverImage == nil)
        {
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Programming.cellImageDummy256" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            coverImage = [sheet image];
        }
        
        _imageView = [[UIImageView alloc] initWithImage:coverImage];

        CGFloat size = COVER_SIZE;
        CGFloat height = (COVER_SIZE + 2*BORDER);
        _imageView.frame = CGRectMake(BORDER, (height - size) / 2.f, size, size);

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



















@end
