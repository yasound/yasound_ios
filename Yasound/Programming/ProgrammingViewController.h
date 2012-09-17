//
//  ProgrammingViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "YaViewController.h"
#import "WheelSelector.h"
#import "Radio.h"
#import "TopBarBackAndTitle.h"

#define RADIOSEGMENT_INDEX_TITLES 0
#define RADIOSEGMENT_INDEX_ARTISTS 1

#define LOCALSEGMENT_INDEX_PLAYLISTS 0
#define LOCALSEGMENT_INDEX_GENRES 1
#define LOCALSEGMENT_INDEX_TITLES 2


#define PROGRAMMING_WHEEL_NB_ITEMS 4
#define PROGRAMMING_WHEEL_ITEM_YASOUND 0
#define PROGRAMMING_WHEEL_ITEM_LOCAL 1
#define PROGRAMMING_WHEEL_ITEM_RADIO 2
#define PROGRAMMING_WHEEL_ITEM_UPLOADS 3
//#define WHEEL_ITEM_SERVER 3

@interface ProgrammingViewController : YaViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, WheelSelectorDelegate, TopBarBackAndTitleDelegate>
{
//    IBOutlet UIBarButtonItem* _synchroBtn;
    
    IBOutlet UILabel* _titleLabel;
    IBOutlet UILabel* _subtitleLabel;
//    IBOutlet UIToolbar* _toolbar;
    
    IBOutlet UIView* _containerRadioSegment;
    IBOutlet UIView* _containerLocalSegment;
    IBOutlet UIView* _containerUploadSegment;
    IBOutlet UISegmentedControl* _radioSegment;
    IBOutlet UISegmentedControl* _localSegment;
    
//    IBOutlet UITableView* _tableView;
}

@property (nonatomic, retain) IBOutlet UIView* container;
@property (nonatomic, retain) IBOutlet WheelSelector* wheelSelector;
@property (nonatomic, retain) IBOutlet TopBarBackAndTitle* topbar;

@property (nonatomic, retain) Radio* radio;
@property (nonatomic, retain) UITableViewController* tableview;

//@property (nonatomic, retain) NSMutableDictionary* sortedSongs;
//@property (nonatomic, retain) NSMutableDictionary* sortedArtists;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forRadio:(Radio*)radio;


@end
