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
    IBOutlet UIToolbar* _toolbar;
    IBOutlet UISegmentedControl* _segment;
    
    IBOutlet UIView* _container;
    
    
    UITableView* _titlesView;
    UITableView* _artistsView;
    UITableView* _albumsView;
    UITableView* _songsView;

    
    NSMutableArray* _data;
    NSInteger _nbReceivedData;
    NSInteger _nbPlaylists;
}

@property (nonatomic, retain) NSMutableDictionary* matchedSongs;
@property (nonatomic, retain) SongCatalog* catalog;


@end
