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
@synthesize wheelSelector;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forRadio:(Radio*)radio
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.radio = radio;
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationNeedGuiRefresh:) name:NOTIF_SONG_GUI_NEED_REFRESH object:nil];
    

    
    
    _titleLabel.text = NSLocalizedString(@"SongUpload_title", nil);
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);    
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
//    if (tableView == _settingsTableView)
//        return [self titleInSettingsTableViewForHeaderInSection:section];
//    
//    return nil;
//}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [SongUploadManager main].items.count; 
}



//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{    
//    return 44;
//}


//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 22;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 22;
//}








//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
//{
//    return gIndexMap;
//}
//
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index 
//{
//    return index;
//}




//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    NSString* title = nil;
//    
//    if (section == 0)
//        return nil;
//    
//    if (section == SECTION_MONTHCHART)
//        title = NSLocalizedString(@"StatsView_monthselector_label", nil);
//    
//    else if (section == SECTION_LEADERBOARD)
//        title = NSLocalizedString(@"StatsView_leaderboardselector_label", nil);
//    
//    
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Menu.MenuSection" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    
//    UIImage* image = [sheet image];
//    CGFloat height = image.size.height;
//    UIImageView* view = [[UIImageView alloc] initWithImage:image];
//    view.frame = CGRectMake(0, 0, tableView.bounds.size.width, height);
//    
//    sheet = [[Theme theme] stylesheetForKey:@"Menu.MenuSectionTitle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    UILabel* label = [sheet makeLabel];
//    label.text = title;
//    [view addSubview:label];
//    
//    return view;
//}




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
        
//        // button "delete"
//        UIImage* image = [UIImage imageNamed:@"CellButtonDel.png"];
//        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(cell.frame.size.width - image.size.width, 0, image.size.width, image.size.height)];
//        [button setImage:image forState:UIControlStateNormal];
//        [button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [cell addSubview:button];
//    }
//    
//    
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Uploads.SongUpload_name" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    UILabel* label = [sheet makeLabel];
//    label.text = [NSString stringWithFormat:@"%@ - %@", item.song.name, item.song.artist];
//    [cell addSubview:label];
//    
//    sheet = [[Theme theme] stylesheetForKey:@"Uploads.SongUpload_progress" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    UIProgressView* progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
//    progressView.frame = sheet.frame;
//    [cell addSubview:progressView];
//    
    
//    ,     // normal progress bar
//                                   UIProgressViewStyleDefault UIProgressViewStyleBar, 
    
    
    
//    
//    Song* song = [self.matchedSongs objectAtIndex:indexPath.row];
//    
//    cell.textLabel.text = song.name;
//    cell.textLabel.backgroundColor = [UIColor clearColor];
//    if ([song isSongEnabled])
//    {
//        cell.textLabel.textColor = [UIColor whiteColor];
//        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1];
//    }
//    else 
//    {
//        cell.textLabel.textColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1];
//        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
//    }
//    
//    
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", song.album, song.artist];
//    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
//    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    Song* song = [self.matchedSongs objectAtIndex:indexPath.row];
//    SongViewController* view = [[SongViewController alloc] initWithNibName:@"SongViewController" bundle:nil song:song];
//    [self.navigationController pushViewController:view animated:YES];
//    [view release];
    
}






- (void)onNotificationNeedGuiRefresh:(NSNotification*)notif
{
    [_tableView reloadData];
}






#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onButtonClicked:(id)sender
{

}










#pragma mark - WheelSelectorDelegate


#define WHEEL_NB_ITEMS 3
#define WHEEL_ITEM_LOCAL 0
#define WHEEL_ITEM_RADIO 1
#define WHEEL_ITEM_UPLOADS 2
//#define WHEEL_ITEM_SERVER 3

- (NSInteger)numberOfItemsInWheelSelector:(WheelSelector*)wheel
{
    return WHEEL_NB_ITEMS;
}

- (NSString*)wheelSelector:(WheelSelector*)wheel titleForItem:(NSInteger)itemIndex
{
    if (itemIndex == WHEEL_ITEM_LOCAL)
        return NSLocalizedString(@"Programming.Catalog.local", nil);
    if (itemIndex == WHEEL_ITEM_RADIO)
        return NSLocalizedString(@"Programming.Catalog.radio", nil);
    //    if (itemIndex == WHEEL_ITEM_SERVER)
    //        return NSLocalizedString(@"Programming.Catalog.server", nil);
    if (itemIndex == WHEEL_ITEM_UPLOADS)
        return NSLocalizedString(@"Programming.Catalog.uploads", nil);
    return nil;
}

- (NSInteger)initIndexForWheelSelector:(WheelSelector*)wheel
{
    return WHEEL_ITEM_RADIO;
}

- (void)wheelSelector:(WheelSelector*)wheel didSelectItemAtIndex:(NSInteger)itemIndex
{
    if (itemIndex == WHEEL_ITEM_LOCAL)
    {
        ProgrammingLocalViewController* view = [[ProgrammingLocalViewController alloc] initWithNibName:@"ProgrammingLocalViewController" bundle:nil forRadio:self.radio];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else if (itemIndex == WHEEL_ITEM_RADIO)
    {
        ProgrammingRadioViewController* view = [[ProgrammingRadioViewController alloc] initWithNibName:@"ProgrammingRadioViewController" bundle:nil  forRadio:self.radio];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else if (itemIndex == WHEEL_ITEM_UPLOADS)
    {
//        ProgrammingUploadViewController* view = [[ProgrammingUploadViewController alloc] initWithNibName:@"ProgrammingUploadViewController" bundle:nil];
//        [self.navigationController pushViewController:view animated:YES];
//        [view release];
    }
}




@end
