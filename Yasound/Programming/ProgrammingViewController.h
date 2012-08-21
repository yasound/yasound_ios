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
#import "TopBar.h"

#define SEGMENT_INDEX_ALPHA 0
#define SEGMENT_INDEX_ARTIST 1


@interface ProgrammingViewController : YaViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, WheelSelectorDelegate, TopBarDelegate>
{
//    IBOutlet UIBarButtonItem* _synchroBtn;
    
    IBOutlet UILabel* _titleLabel;
    IBOutlet UILabel* _subtitleLabel;
    IBOutlet UIToolbar* _toolbar;
    IBOutlet UISegmentedControl* _segment;
    
//    IBOutlet UITableView* _tableView;
}

@property (nonatomic, retain) IBOutlet UIView* container;

@property (nonatomic, retain) Radio* radio;
@property (nonatomic, retain) UITableViewController* tableview;

//@property (nonatomic, retain) NSMutableDictionary* sortedSongs;
//@property (nonatomic, retain) NSMutableDictionary* sortedArtists;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forRadio:(Radio*)radio;


@end
