//
//  MyYasoundViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 25/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyYasoundViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
  UIView* _viewCurrent;
  IBOutlet UIToolbar* _toolbar;
  IBOutlet UIBarButtonItem* _segmentBarButtonItem;
  UISegmentedControl* _segmentControl;
  
    NSArray* _playlists;                   // NSArray of MPMediaPlaylist*
    NSMutableArray* _playlistsDesc;        // NSArray of NSDictionary {name, count}
    NSMutableArray* _selectedPlaylists;    // NSMutableArray of MPMediaPlaylist*
  
  // my yasound settings
  IBOutlet UITableView* _settingsTableView;

  IBOutlet UITableViewCell* _settingsGotoCell;
  IBOutlet UILabel* _settingsGotoLabel;

  
  IBOutlet UITableViewCell* _settingsSubmitCell;
  IBOutlet UILabel* _settingsSubmitTitle;
  
  
  // radio selection  
  IBOutlet UITableView* _tableView;  
    
}

//LBDEBUG
extern NSArray* gFakeUsersFriends;
extern NSArray* gFakeUsersFavorites;


@property (nonatomic, retain) IBOutlet UIView* viewContainer;
@property (nonatomic, retain) IBOutlet UIView* viewMyYasound;
@property (nonatomic, retain) IBOutlet UIView* viewSelection;


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabIcon:(NSString*)tabIcon;
- (IBAction)onmSegmentClicked:(id)sender;
- (IBAction)onSubmitClicked:(id)sender;

@end



@interface MyYasoundViewController (Settings)

- (void)viewDidLoadInSettingsTableView;
- (void)deallocInSettingsTableView;

- (NSString*)titleInSettingsTableViewForHeaderInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInSettingsTableView;
- (NSInteger)numberOfRowsInSettingsTableViewSection:(NSInteger)section;
- (void)willDisplayCellInSettingsTableView:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath;
- (UITableViewCell *)cellInSettingsTableViewForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectInSettingsTableViewRowAtIndexPath:(NSIndexPath *)indexPath;

@end



@interface MyYasoundViewController (RadioSelection)

- (void)deallocInRadioSelection;
- (NSInteger)numberOfSectionsInSelectionTableView;
- (NSInteger)numberOfRowsInSelectionTableViewSection:(NSInteger)section;
- (UITableViewCell *)cellInSelectionTableViewForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectInSelectionTableViewRowAtIndexPath:(NSIndexPath *)indexPath;

@end
