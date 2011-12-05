//
//  MyYasoundViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 25/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyYasoundViewController : UIViewController
{
    UIView* _viewCurrent;
    IBOutlet UIToolbar* _toolbar;
    IBOutlet UIBarButtonItem* _segmentBarButtonItem;
    UISegmentedControl* _segmentControl;
    
    // my yasound settings
    IBOutlet UITableView* _settingsTableView;
    
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

@end



@interface MyYasoundViewController (Settings)

- (NSInteger)numberOfSectionsInSettingsTableView;
- (NSInteger)numberOfRowsInSettingsTableViewSection:(NSInteger)section;
- (UITableViewCell *)cellInSettingsTableViewForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectInSettingsTableViewRowAtIndexPath:(NSIndexPath *)indexPath;

@end



@interface MyYasoundViewController (RadioSelection)

- (NSInteger)numberOfSectionsInSelectionTableView;
- (NSInteger)numberOfRowsInSelectionTableViewSection:(NSInteger)section;
- (UITableViewCell *)cellInSelectionTableViewForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectInSelectionTableViewRowAtIndexPath:(NSIndexPath *)indexPath;

@end
