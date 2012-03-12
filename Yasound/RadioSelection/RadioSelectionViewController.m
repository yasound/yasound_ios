//
//  RadioSelectionViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioSelectionViewController.h"
#import "RadioSelectionTableViewCell.h"
#import "StyleSelectorViewController.h"
#import "RadioViewController.h"
#import "YasoundDataCache.h"
#import "AudioStreamManager.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "TimeProfile.h"

@implementation RadioSelectionViewController


#define TIMEPROFILE_CELL_BUILD @"TimeProfileCellBuild"

//#define TEST_FAKE 0


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil type:(RadioSelectionType)type
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        _type = type;
        
//        UIImage* tabImage = [UIImage imageNamed:tabIcon];
//        UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:title image:tabImage tag:0];
//        self.tabBarItem = theItem;
//        [theItem release];      
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return self;
}

- (void)dealloc
{
  [_tableView release];
  [_qualitySwitchLabel release];
  [_topBarTitle release];
  [_categoryTitle release];
  [_nowPlayingButton release];
  [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString* title = nil;
    if (_type == RSTSelection)
        title = NSLocalizedString(@"MenuView_radios_selection", nil);
    else if (_type == RSTTop)
        title = NSLocalizedString(@"MenuView_radios_top", nil);
    
    _topBarTitle.text = title;
    
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MenuBackground" error:nil];    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
    
    //  _topBarTitle.text = NSLocalizedString(@"FavoritesView_title", nil);
    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);
    
    [_qualitySwitchLabel loadView];
    
    // now playing button
    //    UIButton* btn = [[UIButton alloc] initWithFrame:frame];
    
    
    NSString* str;
    
    _currentStyle = @"style_all";
    _categoryTitle.text = NSLocalizedString(_currentStyle, nil) ;

#ifdef TEST_FAKE
    _radios = [[NSMutableArray alloc] init];
    [_radios retain];
    for (int i = 0; i < 32; i++)
    {
        Radio* radio = [[Radio alloc] init];
        radio.name = [NSString stringWithFormat:@"radio %d", i];
        radio.genre = [NSString stringWithFormat:@"genre %d", i];
        radio.picture = nil;
        radio.likes = [NSNumber numberWithInteger:456];
        radio.favorites = [NSNumber numberWithInteger:654];
        
        [_radios addObject:radio];
    }
    
    [_tableView reloadData];
#endif
    
    
    [self updateRadios:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([AudioStreamManager main].currentRadio == nil)
        [_nowPlayingButton setEnabled:NO];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}















#pragma mark - TableView Source and Delegate




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (!_radios)
        return 0;
    return [_radios count];
}






- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *cellIdentifier = @"RadioSelectionTableViewCell";
    
    if (!_radios)
        return nil;
    
    //[[TimeProfile main] begin:TIMEPROFILE_CELL_BUILD];
    
    RadioSelectionTableViewCell* cell = (RadioSelectionTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    NSInteger rowIndex = indexPath.row;
    Radio* radio = [_radios objectAtIndex:rowIndex];
    
    if (cell == nil)
    {    
        cell = [[RadioSelectionTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier rowIndex:rowIndex radio:radio];
    }
    else
    {
        [cell updateWithRadio:radio rowIndex:rowIndex];
    }

    //[[TimeProfile main] end:TIMEPROFILE_CELL_BUILD];
    //[[TimeProfile main] logInterval:TIMEPROFILE_CELL_BUILD inMilliseconds:YES];
    //[[TimeProfile main] logAverageInterval:TIMEPROFILE_CELL_BUILD inMilliseconds:YES];

    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RadioSelectionTableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
    
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:cell.radio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];  
}






#pragma  mark - Update

- (void)updateRadios:(NSString*)genre
{
    NSString* g = genre;
    if ([genre isEqualToString:@"style_all"])
        g= nil;
    
    if (_type == RSTTop)
        [[YasoundDataCache main] requestRadios:REQUEST_RADIOS_TOP withGenre:g target:self action:@selector(receiveRadios:withInfo:)];
    else if (_type == RSTSelection)
        [[YasoundDataCache main] requestRadios:REQUEST_RADIOS_SELECTION withGenre:g target:self action:@selector(receiveRadios:withInfo:)];
}




- (void)receiveRadios:(NSArray*)radios withInfo:(NSDictionary*)info
{
#ifdef TEST_FAKE
    return;
#endif
    NSError* error = [info valueForKey:@"error"];
    if (error)
    {
        NSLog(@"can't get radios: %@", error.domain);
        return;
    }
    
    _radios = radios;
    [_tableView reloadData];
}







#pragma mark - IBActions

- (IBAction)onStyleSelectorClicked:(id)sender
{
    StyleSelectorViewController* view = [[StyleSelectorViewController alloc] initWithNibName:@"StyleSelectorViewController" bundle:nil currentStyle:_currentStyle target:self];
    //  self.navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self.navigationController presentModalViewController:view animated:YES];
}


- (IBAction)onNowPlayingClicked:(id)sender
{
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:[AudioStreamManager main].currentRadio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (IBAction)menuBarItemClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}






#pragma mark - StyleSelectorDelegate

- (void)didSelectStyle:(NSString*)style
{
    //  [self.navigationController dismissModalViewControllerAnimated:YES];
    
    _currentStyle = style;
    _categoryTitle.text = NSLocalizedString(_currentStyle, nil);
    
    [self updateRadios:_currentStyle];
}

- (void)closeSelectStyleController
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}



@end
