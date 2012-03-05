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
#import "SongUploadViewController.h"
#import "SongAddViewController.h"
#import "TimeProfile.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "SongCatalog.h"
#import "SongUploader.h"
#import "SongUploadManager.h"
#import "RootViewController.h"




@implementation ProgrammingAlbumViewController

@synthesize catalog;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil usingCatalog:(SongCatalog*)catalog
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.catalog = catalog;
    }
    return self;
}


- (void)dealloc
{
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongAdded:) name:NOTIF_PROGAMMING_SONG_ADDED object:nil];
    

    if (self.catalog == [SongCatalog synchronizedCatalog])
        _titleLabel.text = NSLocalizedString(@"ProgrammingView_title", nil);
    else if (self.catalog == [SongCatalog availableCatalog])
        _titleLabel.text = NSLocalizedString(@"SongAddView_title", nil);
        
    _subtitleLabel.text = self.catalog.selectedAlbum;
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    
    if (self.catalog == [SongCatalog synchronizedCatalog])
    {
//        _addBtn TODO ADD BUTTON
        
    }
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
    UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellPlainRow.png"]];
    cell.backgroundView = view;
    [view release];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    NSString* charIndex = [self.catalog.indexMap objectAtIndex:indexPath.section];
    
    Song* song = [self.catalog getSongAtRow:indexPath.row];
    
    if ([song isSongEnabled])
    {
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1];
    }
    else 
    {
        cell.textLabel.textColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d. %@", indexPath.row+1, song.name];

    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    
    Song* song = [self.catalog getSongAtRow:indexPath.row];
    
    if (self.catalog == [SongCatalog synchronizedCatalog])
    {
        SongInfoViewController* view = [[SongInfoViewController alloc] initWithNibName:@"SongInfoViewController" bundle:nil song:song];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else if (self.catalog == [SongCatalog availableCatalog])
    {
        BOOL can = [[SongUploader main] canUploadSong:song];
        if (!can)
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SongAddView_cant_add_title", nil) message:NSLocalizedString(@"SongAddView_cant_add_message", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            [av release];  
            return;
        }
        
        // add an upload job to the queue
        [[SongUploadManager main] addAndUploadSong:song];
        
        // and flag the current song as "uploading song"
        song.uploading = YES;
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell setNeedsLayout];
        
        [ActivityAlertView showWithTitle:NSLocalizedString(@"SongAddView_added", nil) closeAfterTimeInterval:1];
    }

}












#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSynchronize:(id)semder
{
    SongUploadViewController* view = [[SongUploadViewController alloc] initWithNibName:@"SongUploadViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}


- (IBAction)onAdd:(id)sender
{
    SongAddViewController* view = [[SongAddViewController alloc] initWithNibName:@"SongAddViewController" bundle:nil withMatchedSongs:[SongCatalog synchronizedCatalog].matchedSongs];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}



- (void)onNotifSongAdded:(NSNotification*)notif
{
    [_tableView reloadData];    
}



@end
