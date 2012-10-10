//
//  ProgrammingUploadViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProgrammingUploadViewController.h"
#import "SongUploadManager.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "SongUploadCell.h"
#import "ProgrammingLocalViewController.h"
#import "ProgrammingRadioViewController.h"

@interface ProgrammingUploadViewController ()

@end 

@implementation ProgrammingUploadViewController

@synthesize radio;



- (id)initWithStyle:(UITableViewStyle)style forRadio:(Radio*)radio
{
    self = [super initWithStyle:style];
    if (self)
    {
        self.radio = radio;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"commonGradient.png"]];

        [self load];
    
    }
    return self;
}

- (void)load
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationNeedGuiRefresh:) name:NOTIF_SONG_GUI_NEED_REFRESH object:nil];
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
    return [SongUploadManager main].items.count; 
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
    static NSString* CellIdentifier = @"Cell";
    
    SongUploadCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    SongUploadItem* item = [[SongUploadManager main].items objectAtIndex:indexPath.row];
    
    if (cell == nil) 
    {
        cell = [[[SongUploadCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier mediaItem:item] autorelease];
    }
    else
    {
        [cell update:item];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}






- (void)onNotificationNeedGuiRefresh:(NSNotification*)notif
{
    [self.tableView reloadData];
}






#pragma mark - IBActions


- (void)setSegment:(NSInteger)index
{
}



- (BOOL)onBackClicked
{
    return YES;
}






@end
