//
//  ProgrammingViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProgrammingViewController.h"
#import "ActivityAlertView.h"
#import "YasoundRadio.h"
#import "YasoundDataProvider.h"
#import "SongInfoViewController.h"
#import "ProgrammingRadioViewController.h"
#import "ProgrammingUploadViewController.h"
#import "ProgrammingLocalViewController.h"
#import "ProgrammingSearchYasoundViewController.h"
#import "TimeProfile.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "SongRadioCatalog.h"
#import "SongLocalCatalog.h"
#import "ProgrammingArtistViewController.h"
#import "RootViewController.h"
#import "AudioStreamManager.h"
#import "ProgrammingCell.h"
#import "DataBase.h"

@implementation ProgrammingViewController

@synthesize radio;
@synthesize container;
@synthesize viewController;
@synthesize topbar;

#define SEGMENT_INDEX_ALPHA 0
#define SEGMENT_INDEX_ARTIST 1


#define TIMEPROFILE_BUILD @"Programming build catalog"



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forRadio:(YasoundRadio*)radio
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.radio = radio;
        
        // anti-bug
        NSString* catalogId = [NSString stringWithFormat:@"%@", [SongRadioCatalog main].radio.id];
        NSString* newId = [NSString stringWithFormat:@"%@", self.radio.id];
        
        // clean catalog
        if (([SongRadioCatalog main].radio.id != nil) && ![catalogId isEqualToString:newId])
        {
            [SongRadioCatalog releaseCatalog];
//            [DataBase releaseDataBase];
        }
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}





- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongAdded:) name:NOTIF_PROGAMMING_SONG_ADDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongRemoved:) name:NOTIF_PROGAMMING_SONG_REMOVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifProgrammingTitle:) name:NOTIF_PROGRAMMING_TITLE object:nil];
    
    [_radioSegment setTitle:NSLocalizedString(@"Programming.segment.titles", nil) forSegmentAtIndex:0];
    [_radioSegment setTitle:NSLocalizedString(@"Programming.segment.artists", nil) forSegmentAtIndex:1];

    [_localSegment setTitle:NSLocalizedString(@"Programming.segment.playlists", nil) forSegmentAtIndex:0];
    [_localSegment setTitle:NSLocalizedString(@"Programming.segment.genres", nil) forSegmentAtIndex:1];
    [_localSegment setTitle:NSLocalizedString(@"Programming.segment.titles", nil) forSegmentAtIndex:2];
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







#pragma mark - IBActions



- (IBAction)onRadioSegmentClicked:(id)sender
{
    NSInteger index = _radioSegment.selectedSegmentIndex;
    
    [self.viewController setSegment:index];
}


- (IBAction)onLocalSegmentClicked:(id)sender
{
    NSInteger index = _localSegment.selectedSegmentIndex;
    
    [self.viewController setSegment:index];
}


- (IBAction)onReloadClicked:(id)sender {


    // reset catalogs
    [SongRadioCatalog releaseCatalog];
//    [SongLocalCatalog releaseCatalog];
//    [DataBase releaseDataBase];

    [self.wheelSelector stickToItem:PROGRAMMING_WHEEL_ITEM_RADIO silent:NO];


    
    // refresh catalog and gui
//    if ([self.viewController respondsToSelector:@selector(load)])
//        [self.viewController load];
    
    
}


- (void)onNotifSongAdded:(NSNotification*)notif
{
}


- (void)onNotifSongRemoved:(NSNotification*)notif
{    
    UIViewController* sender = notif.object;
}


- (void)onNotifProgrammingTitle:(NSNotification*)notif {
    
    NSString* title = notif.object;
    self.topbarSubtitle.text = title;
}







#pragma mark - WheelSelectorDelegate



- (NSInteger)numberOfItemsInWheelSelector:(WheelSelector*)wheel
{
    return PROGRAMMING_WHEEL_NB_ITEMS;
}

- (NSString*)wheelSelector:(WheelSelector*)wheel titleForItem:(NSInteger)itemIndex
{
    if (itemIndex == PROGRAMMING_WHEEL_ITEM_YASOUND_SERVER)
        return NSLocalizedString(@"Programming.Catalog.yasound", nil);
    if (itemIndex == PROGRAMMING_WHEEL_ITEM_LOCAL)
        return NSLocalizedString(@"Programming.Catalog.local", nil);
    if (itemIndex == PROGRAMMING_WHEEL_ITEM_RADIO)
        return NSLocalizedString(@"Programming.Catalog.radio", nil);
    if (itemIndex == PROGRAMMING_WHEEL_ITEM_UPLOADS)
        return NSLocalizedString(@"Programming.Catalog.uploads", nil);
    return nil;
}

- (NSInteger)initIndexForWheelSelector:(WheelSelector*)wheel
{
    return PROGRAMMING_WHEEL_ITEM_RADIO;
}

- (void)wheelSelector:(WheelSelector*)wheel didSelectItemAtIndex:(NSInteger)itemIndex
{
    if (self.viewController != nil)
    {
        if ([self.viewController isKindOfClass:[UITableViewController class]])
        {
            UITableViewController* tableViewController = (UITableViewController*)self.viewController;
            [tableViewController.tableView removeFromSuperview];
        }
        else if ([self.viewController isKindOfClass:[ProgrammingSearchYasoundViewController class]])
        {
            ProgrammingSearchYasoundViewController* searchController = (ProgrammingSearchYasoundViewController*)self.viewController;
            [searchController.view removeFromSuperview];
        }
        [self.viewController release];
        self.viewController = nil;
    }
    
    self.topbarTitle.text = @"";
    self.topbarSubtitle.text = @"";
    

    if (itemIndex == PROGRAMMING_WHEEL_ITEM_LOCAL)
    {
        _containerLocalSegment.hidden = NO;
        _containerRadioSegment.hidden = YES;
        _containerEmptySegment.hidden = YES;
        
        ProgrammingLocalViewController* view = [[ProgrammingLocalViewController alloc] initWithStyle:UITableViewStylePlain forRadio:self.radio withSegmentIndex:_localSegment.selectedSegmentIndex];
        self.viewController = view;
        
//        self.topbarTitle.text = @"";
//        self.topbarSubtitle.text = [view title];
    }
    else if (itemIndex == PROGRAMMING_WHEEL_ITEM_RADIO)
    {
        _containerLocalSegment.hidden = YES;
        _containerRadioSegment.hidden = NO;
        _containerEmptySegment.hidden = YES;

        ProgrammingRadioViewController* view = [[ProgrammingRadioViewController alloc] initWithStyle:UITableViewStylePlain forRadio:self.radio];
        self.viewController = view;

//        self.topbarTitle.text = @"";
//        self.topbarSubtitle.text = [view title];
    }
    else if (itemIndex == PROGRAMMING_WHEEL_ITEM_UPLOADS)
    {
        _containerLocalSegment.hidden = YES;
        _containerRadioSegment.hidden = YES;
        _containerEmptySegment.hidden = NO;

        ProgrammingUploadViewController* view = [[ProgrammingUploadViewController alloc] initWithStyle:UITableViewStylePlain forRadio:self.radio];
        self.viewController = view;

//        self.topbarTitle.text = @"";
//        self.topbarSubtitle.text = @"";
    }
    else if (itemIndex == PROGRAMMING_WHEEL_ITEM_YASOUND_SERVER)
    {
        _containerLocalSegment.hidden = YES;
        _containerRadioSegment.hidden = YES;
        _containerEmptySegment.hidden = NO;
        
        ProgrammingSearchYasoundViewController* view = [[ProgrammingSearchYasoundViewController alloc] initWithNibName:@"ProgrammingSearchYasoundViewController" bundle:nil andRadio:self.radio];
        self.viewController = view;

//        self.topbarTitle.text = @"";
//        self.topbarSubtitle.text = @"";
}
    
    
    if ([self.viewController isKindOfClass:[UITableViewController class]])
    {
        UITableViewController* tableViewController = (UITableViewController*)self.viewController;
        tableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        CGRect frame = CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height);
        tableViewController.tableView.frame = frame;
        [self.container addSubview:tableViewController.tableView];
    }
    else if ([self.viewController isKindOfClass:[ProgrammingSearchYasoundViewController class]])
    {
        ProgrammingSearchYasoundViewController* searchViewController = (ProgrammingSearchYasoundViewController*)self.viewController;
        CGRect frame = CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height);
        searchViewController.view.frame = frame;
        [self.container addSubview:searchViewController.view];
    }
    
}








#pragma mark - TopBarBackAndTitleDelegate

- (BOOL)topBarBackClicked
{
    BOOL goBack = [self.viewController onBackClicked];
    return goBack;
}




@end
