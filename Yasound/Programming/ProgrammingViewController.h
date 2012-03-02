//
//  ProgrammingViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "TestflightViewController.h"
#import "SongCatalog.h"

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
}

@property (nonatomic, retain) NSMutableDictionary* matchedSongs;
@property (nonatomic, retain) SongCatalog* catalog;

@end
