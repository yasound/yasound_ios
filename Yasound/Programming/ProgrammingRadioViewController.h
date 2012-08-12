//
//  ProgrammingRadioViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "TestflightViewController.h"
#import "WheelSelector.h"



@interface ProgrammingRadioViewController : TestflightViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, WheelSelectorDelegate>
{
    IBOutlet UIBarButtonItem* _backBtn;
    IBOutlet UIBarButtonItem* _addBtn;
    IBOutlet UIBarButtonItem* _synchroBtn;
    IBOutlet UIBarButtonItem* _nowPlayingButton;
    
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
@property (nonatomic, retain) NSMutableDictionary* sortedSongs;
@property (nonatomic, retain) NSMutableDictionary* sortedArtists;


@end
