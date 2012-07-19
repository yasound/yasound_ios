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
#import "WheelSelector.h"

@implementation RadioSelectionViewController

@synthesize url;
@synthesize tableview;

#define TIMEPROFILE_CELL_BUILD @"TimeProfileCellBuild"



- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withUrl:(NSURL*)url
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.url = url;
    }
    return self;
}

- (void)dealloc
{
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
    
    [self updateRadios:nil];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
        g = nil;
    
    [[YasoundDataCache main] requestRadiosWithUrl:self.url withGenre:g target:self action:@selector(receiveRadios:info:)];
}




- (void)receiveRadios:(NSArray*)radios info:(NSDictionary*)info
{
#ifdef TEST_FAKE
    return;
#endif
    NSError* error = [info valueForKey:@"error"];
    if (error)
    {
        DLog(@"can't get radios: %@", error.domain);
        return;
    }
    
    _radios = radios;
    [_tableView reloadData];
}







#pragma mark - TopBarDelegate

- (void)topBarBackItemClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)topBarNowPlayingClicked
{
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:[AudioStreamManager main].currentRadio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

#pragma mark - WheelSelectorDelegate

// item has been selected from the wheel selector
- (void)wheelSelectorDidSelect:(NSInteger)index
{
    if (self.tableview != nil)
        [self.tableview removeFromSuperview];
    self.tableview = nil;
    
    NSString* url = nil;

    // request favorites radios
    if (index == WheelIdFavorites)
    {
        NSString* g = nil;
        
        NSDictionary* entry = [[YasoundDataCache main] menuEntry:MENU_ENTRY_ID_FAVORITES];
        assert(entry);
        url = [[YasoundDataCache main] entryParameter:MENU_ENTRY_PARAM_URL forEntry:entry];        
    }

    // request selection radios
    else if (index == WheelIdSelection)
    {
        NSString* g = nil;
        
        NSDictionary* entry = [[YasoundDataCache main] menuEntry:MENU_ENTRY_ID_SELECTION];
        assert(entry);
        url = [[YasoundDataCache main] entryParameter:MENU_ENTRY_PARAM_URL forEntry:entry];        
    }

    // request top radios
    else if (index == WheelIdTop)
    {
        NSString* g = nil;
        
        NSDictionary* entry = [[YasoundDataCache main] menuEntry:MENU_ENTRY_ID_FAVORITES];
        assert(entry);
        url = [[YasoundDataCache main] entryParameter:MENU_ENTRY_PARAM_URL forEntry:entry];            
    }

    
    [[YasoundDataCache main] requestRadiosWithUrl:self.url withGenre:g target:self action:@selector(receiveRadios:info:)];
        
}






@end
