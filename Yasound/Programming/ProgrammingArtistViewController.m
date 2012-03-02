//
//  ProgrammingArtistViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProgrammingArtistViewController.h"
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
#import "ProgrammingAlbumViewController.h"

@implementation ProgrammingArtistViewController





- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
    }
    return self;
}


- (void)dealloc
{
    [super dealloc];
}





- (void)viewDidLoad
{
    [super viewDidLoad];

    _titleLabel.text = NSLocalizedString(@"ProgrammingView_title", nil);
    _subtitleLabel.text = NSLocalizedString(@"ProgrammingView_subtitle", nil);
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
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














#pragma mark - TableView Source and Delegate


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
//{
//    return [gIndexMap objectAtIndex:section];
//}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 22;
//}
//


//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    NSString* title = nil;
//    
//    NSInteger nbRows = [self getNbRowsForTable:tableView inSection:section];
//
//    if (nbRows == 0)
//        return nil;
//    
//    if (tableView == _titlesView)
//        title = [[SongCatalog programmingCatalog].indexMap objectAtIndex:section];
//    else if (tableView == _artistsView)
//        title = [[SongCatalog programmingCatalog].indexMap objectAtIndex:section];
//    else if (tableView == _albumsView)
//        title = [SongCatalog programmingCatalog].selectedArtist;
//    else if (tableView == _songsView)
//        title = [SongCatalog programmingCatalog].selectedAlbum;
//    
//    
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MenuSection" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    
//    UIImageView* view = [[UIImageView alloc] initWithImage:[sheet image]];
//    view.frame = CGRectMake(0, 0, tableView.bounds.size.width, 44);
//    
//    sheet = [[Theme theme] stylesheetForKey:@"MenuSectionTitle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    UILabel* label = [sheet makeLabel];
//    label.text = title;
//    [view addSubview:label];
//    
//    return view;
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSInteger count = [SongCatalog programmingCatalog].selectedArtistRepo.count;
    return count;
}



//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{    
//    return 44;
//}


//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 22;
//}





//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
//{
//    if ((tableView == _titlesView) || (tableView == _artistsView))
//        return [SongCatalog programmingCatalog].indexMap;
//    
//    return nil;
//}


//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index 
//{
//    if ((tableView == _titlesView) || (tableView == _artistsView))
//        return index;
//
//    return 0;
//}






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

    NSString* charIndex = [[SongCatalog programmingCatalog].indexMap objectAtIndex:indexPath.section];
    
    NSArray* albums = [[SongCatalog programmingCatalog].selectedArtistRepo allKeys];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [albums objectAtIndex:indexPath.row];

    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    [[SongCatalog programmingCatalog] selectAlbumAtRow:indexPath.row];

    ProgrammingAlbumViewController* view = [[ProgrammingAlbumViewController alloc] initWithNibName:@"ProgrammingAlbumViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:YES];
    [view release];

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
    SongAddViewController* view = [[SongAddViewController alloc] initWithNibName:@"SongAddViewController" bundle:nil withMatchedSongs:[SongCatalog programmingCatalog].matchedSongs];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}



@end
