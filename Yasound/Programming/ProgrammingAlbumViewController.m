//
//  ProgrammingAlbumViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProgrammingAlbumViewController.h"
#import "ActivityAlertView.h"
#import "Radio.h"
#import "YasoundDataProvider.h"
#import "SongInfoViewController.h"
#import "ProgrammingUploadViewController.h"
#import "ProgrammingLocalViewController.h"
#import "TimeProfile.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "SongCatalog.h"
#import "SongUploader.h"
#import "SongUploadManager.h"
#import "RootViewController.h"
#import "SongAddCell.h"
#import "AudioStreamManager.h"
#import "LocalSongInfoViewController.h"
#import "ProgrammingTitleCell.h"
#import "ProgrammingLocalViewController.h"
#import "ProgrammingRadioViewController.h"


@implementation ProgrammingAlbumViewController

@synthesize radio;
@synthesize catalog;


- (void)dealloc
{
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (id)initWithStyle:(UITableViewStyle)style  usingCatalog:(SongCatalog*)catalog forRadio:(Radio*)radio
{
    self = [super initWithStyle:style];
    if (self)
    {
        self.radio = radio;
        self.catalog = catalog;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        
        [self load];
    }
    return self;
}




- (void)load
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongAdded:) name:NOTIF_PROGAMMING_SONG_ADDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongRemoved:) name:NOTIF_PROGAMMING_SONG_REMOVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationUploadCanceled:) name:NOTIF_SONG_GUI_NEED_REFRESH object:nil];
    

//    if (self.catalog == [SongCatalog synchronizedCatalog])
//        _titleLabel.text = NSLocalizedString(@"ProgrammingView_title", nil);
//    else if (self.catalog == [SongCatalog availableCatalog])
//        _titleLabel.text = NSLocalizedString(@"SongAddView_title", nil);
//        
//    _subtitleLabel.text = self.catalog.selectedAlbum;
//    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
//    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);

    
    if (self.catalog == [SongCatalog synchronizedCatalog])
    {
//        _addBtn TODO ADD BUTTON
        
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    if ([AudioStreamManager main].currentRadio == nil)
//        [_nowPlayingButton setEnabled:NO];
//    else
//        [_nowPlayingButton setEnabled:YES];
    
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
    return self.catalog.selectedAlbumRepo.count;
}








- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.cell" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    cell.backgroundView = [sheet makeImage];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    if (self.catalog == [SongCatalog availableCatalog])
    {
        static NSString* CellAddIdentifier = @"CellAdd";

        Song* song = [self.catalog getSongAtRow:indexPath.row];
        
        SongAddCell* cell = [tableView dequeueReusableCellWithIdentifier:CellAddIdentifier];
        
        if (cell == nil) 
        {
            cell = [[[SongAddCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellAddIdentifier song:song] autorelease];
        }
        else
            [cell update:song];        
        
        return cell;
    }
    
    else
    {
        static NSString* CellIdentifier = @"CellAlbumSong";

        Song* song = [self.catalog getSongAtRow:indexPath.row];
        
        ProgrammingTitleCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) 
        {
            cell = [[[ProgrammingTitleCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier withSong:song atRow:(indexPath.row+1) deletingTarget:self deletingAction:@selector(onSongDeleteRequested:song:)] autorelease];
        }
        else
            [cell updateWithSong:song atRow:(indexPath.row+1)];
        
        return cell;
    }
    
    return nil;
}





- (void)onSongDeleteRequested:(UITableViewCell*)cell song:(Song*)song
{
    DLog(@"onSongDeleteRequested for Song %@", song.name);   
    
    // request to server
    [[YasoundDataProvider main] deleteSong:song target:self action:@selector(onSongDeleted:info:) userData:cell];
    
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
    
    UITableViewCell* cell = [info objectForKey:@"userData"];
    NSIndexPath* indexPath = [self indexPathForCell:cell];
    
    [[SongCatalog synchronizedCatalog] removeSynchronizedSong:song];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PROGAMMING_SONG_REMOVED object:self];

    [self deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}







- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    if (self.catalog == [SongCatalog synchronizedCatalog])
    {
        Song* song = [self.catalog getSongAtRow:indexPath.row];

        SongInfoViewController* view = [[SongInfoViewController alloc] initWithNibName:@"SongInfoViewController" bundle:nil song:song showNowPlaying:YES];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else if (self.catalog == [SongCatalog availableCatalog])
    {
        SongLocal* songLocal = (SongLocal*)[self.catalog getSongAtRow:indexPath.row];

        LocalSongInfoViewController* view = [[LocalSongInfoViewController alloc] initWithNibName:@"SongInfoViewController" bundle:nil song:songLocal];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }

}












#pragma mark - IBActions

- (IBAction)onSynchronize:(id)semder
{
    ProgrammingUploadViewController* view = [[ProgrammingUploadViewController alloc] initWithNibName:@"ProgrammingUploadViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}


//- (IBAction)onAdd:(id)sender
//{
//    ProgrammingLocalViewController* view = [[ProgrammingLocalViewController alloc] initWithNibName:@"ProgrammingLocalViewController" bundle:nil  withMatchedSongs:[SongCatalog synchronizedCatalog].matchedSongs];
//    [self.navigationController pushViewController:view animated:YES];
//    [view release];
//}



- (void)onNotifSongAdded:(NSNotification*)notif
{
    
    [self.tableView reloadData];
}


- (void)onNotifSongRemoved:(NSNotification*)notif
{    
    UIViewController* sender = notif.object;
    
    if (sender != self)
        [self.tableView reloadData];
}



- (void)onNotificationUploadCanceled:(NSNotification*)notif
{
    [self.tableView reloadData];
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
