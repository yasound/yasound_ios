//
//  ProgrammingViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "TestflightViewController.h"

@interface ProgrammingViewController : TestflightViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    IBOutlet UIBarButtonItem* _backBtn;
    IBOutlet UILabel* _titleLabel;
    IBOutlet UILabel* _subtitleLabel;
    IBOutlet UITableView* _tableView;
    IBOutlet UIToolbar* _toolbar;
    IBOutlet UISegmentedControl* _segment;

    
    NSMutableArray* _data;
    NSInteger _nbReceivedData;
    NSInteger _nbPlaylists;
    
    NSCharacterSet* _numericSet;
    NSCharacterSet* _lowerCaseSet;
    NSCharacterSet* _upperCaseSet;
    
}

@property (nonatomic, retain) NSMutableDictionary* matchedSongs;
@property (nonatomic, retain) NSMutableDictionary* alphabeticRepo;
@property (nonatomic, retain) NSMutableDictionary* artistsRepo;
@property (nonatomic, retain) NSArray* artistsRepoKeys;
@property (nonatomic, retain) NSMutableArray* artistsIndexSections;

@end
