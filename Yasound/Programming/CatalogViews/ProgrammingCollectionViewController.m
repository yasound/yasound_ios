//
//  ProgrammingCollectionViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProgrammingCollectionViewController.h"
#import "ActivityAlertView.h"
#import "Radio.h"
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
#import "SongAddCell.h"
#import "AudioStreamManager.h"
#import "LocalSongInfoViewController.h"
#import "ProgrammingCell.h"
#import "ProgrammingLocalViewController.h"
#import "ProgrammingRadioViewController.h"
#import "YasoundAppDelegate.h"
#import "DataBase.h"
#import "PlaylistMoulinor.h"


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


- (id)initWithStyle:(UITableViewStyle)style  usingCatalog:(SongCatalog*)catalog withArtists:(NSArray*)artists forRadio:(Radio*)radio
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
    
//    //LBDEBUG TEMPORARLY
//    NSData* data = [NSData dataWithContentsOfFile:[DataBase main].dbPath];
//    [[PlaylistMoulinor main] emailData:data to:@"neywen@neywen.net" mimetype:@"application/octet-stream" filename:@"catalog.sqlite" controller:self];

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
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        
        //            cell.textLabel.backgroundColor = [UIColor clearColor];
        //            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        //            cell.textLabel.textColor = [UIColor whiteColor];
        //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.disclosureIndicator" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIImageView* di = [sheet makeImage];
        cell.accessoryView = di;
        [di release];
        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.textLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        cell.textLabel.backgroundColor = [sheet fontBackgroundColor];
        cell.textLabel.textColor = [sheet fontTextColor];
        cell.textLabel.font = [sheet makeFont];
        
        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.detailTextLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        cell.detailTextLabel.backgroundColor = [sheet fontBackgroundColor];
        cell.detailTextLabel.textColor = [sheet fontTextColor];
        cell.detailTextLabel.font = [sheet makeFont];
    }
    
    NSString* artist = [self.artists objectAtIndex:indexPath.row];
    
    NSInteger nbAlbums = 0;
    if (self.catalog.selectedGenre)
        nbAlbums = [[SongLocalCatalog main] albumsForArtist:artist withGenre:self.catalog.selectedGenre fromTable:LOCALCATALOG_TABLE].count;
    else if (self.catalog.selectedPlaylist)
        nbAlbums = [[SongLocalCatalog main] albumsForArtist:artist withGenre:self.catalog.selectedPlaylist fromTable:LOCALCATALOG_TABLE].count;
    else
        nbAlbums = [[SongLocalCatalog main] albumsForArtist:artist].count;
    
    cell.textLabel.text = artist;
    
    if (nbAlbums == 1)
        cell.detailTextLabel.text = NSLocalizedString(@"Programming.nbAlbums.1", nil);
    else
        cell.detailTextLabel.text = NSLocalizedString(@"Programming.nbAlbums.n", nil);
    
    cell.detailTextLabel.text = [cell.detailTextLabel.text stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", nbAlbums]];

    return cell;
}





- (void)onSongDeleteRequested:(UITableViewCell*)cell song:(Song*)song
{
    DLog(@"onSongDeleteRequested for Song %@", song.name);
    
    // request to server
    [[YasoundDataProvider main] deleteSong:song target:self action:@selector(onSongDeleted:info:) userData:cell];
    
}







- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
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









//- (void)setSegment:(NSInteger)index
//{
////    self.selectedSegmentIndex = index;
//    
//    if (self.artistVC)
//    {
//        [self.artistVC onBackClicked];
//        [self.artistVC.tableView removeFromSuperview];
//        [self.artistVC release];
//        self.artistVC = nil;
//    }
//    
//    [self.tableView reloadData];
//}
//
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
    
    self.catalog.selectedGenre = nil;
    self.catalog.selectedPlaylist = nil;
    
    return goBack;
}




- (void)removeAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self.artistVC.tableView removeFromSuperview];
    [self.artistVC release];
    self.artistVC = nil;
}





//
//
//#pragma mark - WheelSelectorDelegate
//
//
//#define WHEEL_NB_ITEMS 3
//#define WHEEL_ITEM_LOCAL 0
//#define WHEEL_ITEM_RADIO 1
//#define WHEEL_ITEM_UPLOADS 2
////#define WHEEL_ITEM_SERVER 3
//
//- (NSInteger)numberOfItemsInWheelSelector:(WheelSelector*)wheel
//{
//    return WHEEL_NB_ITEMS;
//}
//
//- (NSString*)wheelSelector:(WheelSelector*)wheel titleForItem:(NSInteger)itemIndex
//{
//    if (itemIndex == WHEEL_ITEM_LOCAL)
//        return NSLocalizedString(@"Programming.Catalog.local", nil);
//    if (itemIndex == WHEEL_ITEM_RADIO)
//        return NSLocalizedString(@"Programming.Catalog.radio", nil);
//    //    if (itemIndex == WHEEL_ITEM_SERVER)
//    //        return NSLocalizedString(@"Programming.Catalog.server", nil);
//    if (itemIndex == WHEEL_ITEM_UPLOADS)
//        return NSLocalizedString(@"Programming.Catalog.uploads", nil);
//    return nil;
//}
//
//- (NSInteger)initIndexForWheelSelector:(WheelSelector*)wheel
//{
//    return WHEEL_ITEM_RADIO;
//}
//
//- (void)wheelSelector:(WheelSelector*)wheel didSelectItemAtIndex:(NSInteger)itemIndex
//{
//    if (itemIndex == WHEEL_ITEM_LOCAL)
//    {
//        ProgrammingLocalViewController* view = [[ProgrammingLocalViewController alloc] initWithNibName:@"ProgrammingLocalViewController" bundle:nil forRadio:self.radio];
//        [self.navigationController pushViewController:view animated:YES];
//        [view release];
//    }
//    else if (itemIndex == WHEEL_ITEM_RADIO)
//    {
//        //        ProgrammingRadioViewController* view = [[ProgrammingRadioViewController alloc] initWithNibName:@"ProgrammingRadioViewController" bundle:nil  forRadio:self.radio];
//        //        [self.navigationController pushViewController:view animated:YES];
//        //        [view release];
//    }
//    else if (itemIndex == WHEEL_ITEM_UPLOADS)
//    {
//        ProgrammingUploadViewController* view = [[ProgrammingUploadViewController alloc] initWithNibName:@"ProgrammingUploadViewController" bundle:nil];
//        [self.navigationController pushViewController:view animated:YES];
//        [view release];
//    }
//}
//
//

@end
