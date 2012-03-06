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
    IBOutlet UIBarButtonItem* _addBtn;
    IBOutlet UIBarButtonItem* _synchroBtn;
    IBOutlet UILabel* _titleLabel;
    IBOutlet UILabel* _subtitleLabel;
    IBOutlet UIToolbar* _toolbar;
    IBOutlet UISegmentedControl* _segment;
    
    IBOutlet UITableView* _tableView;

    
    NSMutableArray* _data;
    NSInteger _nbReceivedData;
    NSInteger _nbPlaylists;
}

@property (nonatomic, retain) NSMutableDictionary* matchedSongs;


@end
