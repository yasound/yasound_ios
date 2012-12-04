//
//  ProgrammingCollectionViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProgrammingCollectionViewController.h"
#import "ActivityAlertView.h"
#import "YaRadio.h"
#import "YasoundDataProvider.h"
#import "SongInfoViewController.h"
#import "ProgrammingUploadViewController.h"
#import "ProgrammingLocalViewController.h"
#import "TimeProfile.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "SongRadioCatalog.h"
#import "SongLocalCatalog.h"
#import "SongUploader.h"
#import "SongUploadManager.h"
#import "RootViewController.h"
#import "ActionAddSongCell.h"
#import "AudioStreamManager.h"
#import "LocalSongInfoViewController.h"
#import "ProgrammingCell.h"
#import "ProgrammingLocalViewController.h"
#import "ProgrammingRadioViewController.h"
#import "YasoundAppDelegate.h"
#import "DataBase.h"
#import "PlaylistMoulinor.h"
#import "ActionAddCollectionCell.h"


@implementation ProgrammingCollectionViewController

@synthesize radio;
@synthesize catalog;
@synthesize artists;
@synthesize artistVC;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if (self.artistVC)
    {
        [self.artistVC onBackClicked];
        [self.artistVC.tableView removeFromSuperview];
        [self.artistVC release];
        self.artistVC = nil;
    }
    
    [super dealloc];
}


- (id)initWithStyle:(UITableViewStyle)style  usingCatalog:(SongCatalog*)catalog withArtists:(NSArray*)artists forRadio:(YaRadio*)radio
{
    self = [super initWithStyle:style];
    if (self)
    {
        self.radio = radio;
        self.catalog = catalog;
        self.artists = artists;
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"commonGradient.png"]];
        
        
        [self load];
    }
    return self;
}




- (void)load
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongAdded:) name:NOTIF_PROGAMMING_SONG_ADDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongRemoved:) name:NOTIF_PROGAMMING_SONG_REMOVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongUpdated:) name:NOTIF_PROGAMMING_SONG_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationUploadCanceled:) name:NOTIF_SONG_GUI_NEED_REFRESH object:nil];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    if (artists == nil)
        return 0;
    return artists.count;
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString* title = nil;
    if (self.catalog.selectedGenre)
        title = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Programming.segment.genre", nil), self.catalog.selectedGenre];
    else
        title = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Programming.segment.playlist", nil), self.catalog.selectedPlaylist];
    
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Programming.Section.background" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImageView* view = [sheet makeImage];
    
    sheet = [[Theme theme] stylesheetForKey:@"Programming.Section.label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = title;
    [view addSubview:label];
    
    return view;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.cell" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    cell.backgroundView = [sheet makeImage];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString* CellIdentifier = @"CellArtist";
    
    //LBDEBUG
    assert(self.artists.count > indexPath.row);

    NSString* artist = [self.artists objectAtIndex:indexPath.row];
    
    ActionAddCollectionCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[ActionAddCollectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier artist:artist subtitle:nil forRadio:self.radio usingCatalog:self.catalog] autorelease];
    }
    else
        [cell updateArtist:artist subtitle:nil];
    
    return cell;
}




//#FIXME: useles ? never called?
- (void)onSongDeleteRequested:(UITableViewCell*)cell song:(Song*)song
{
    DLog(@"onSongDeleteRequested for Song %@", song.name);
    
    // request to server    
    [[YasoundDataProvider main] deleteSong:song withCompletionBlock:^(int status, NSString* response, NSError* error){
        BOOL success = YES;
        if (error)
        {
            DLog(@"delete song error: %d - %@", error.code, error.domain);
            success = NO;
        }
        else if (status != 200)
        {
            DLog(@"delete song error: response status %d", status);
            success = NO;
        }
        
        // ???
    }];
    
}







- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    //LBDEBUG
    assert(self.artists.count > indexPath.row);
    
    NSString* artist = [self.artists objectAtIndex:indexPath.row];
    
    [self.catalog selectArtist:artist withCharIndex:nil];
    
    self.artistVC = [[ProgrammingArtistViewController alloc] initWithStyle:UITableViewStylePlain usingCatalog:self.catalog forRadio:self.radio];
    CGRect frame = CGRectMake(self.view.frame.size.width,0, self.tableView.frame.size.width, self.tableView.frame.size.height);
    self.artistVC.tableView.frame = frame;
    [self.view.superview addSubview:self.artistVC.tableView];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.33];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    frame = CGRectMake(0,0, self.tableView.frame.size.width, self.tableView.frame.size.height);
    self.artistVC.tableView.frame = frame;
    
    [UIView commitAnimations];
}




- (BOOL)onBackClicked
{
    BOOL goBack = YES;
    if (self.artistVC)
    {
        goBack = [self.artistVC onBackClicked];
        
        if (goBack)
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.33];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(removeAnimationDidStop:finished:context:)];
            
            CGRect frame = CGRectMake(self.view.frame.size.width,0, self.tableView.frame.size.width, self.tableView.frame.size.height);
            self.artistVC.tableView.frame = frame;
            
            [UIView commitAnimations];
            

            
            return NO;
        }
    }
    
    
    return goBack;
}




- (void)removeAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self.artistVC.tableView removeFromSuperview];
    [self.artistVC release];
    self.artistVC = nil;
}





@end
