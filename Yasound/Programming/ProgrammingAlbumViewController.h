//
//  ProgrammingAlbumViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "TestflightViewController.h"
#import "SongCatalog.h"
#import "WheelSelector.h"


@interface ProgrammingAlbumViewController : TestflightViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, WheelSelectorDelegate>
{
    IBOutlet UIBarButtonItem* _backBtn;
    IBOutlet UIBarButtonItem* _nowPlayingButton;

    IBOutlet UILabel* _titleLabel;
    IBOutlet UILabel* _subtitleLabel;
    IBOutlet UIToolbar* _toolbar;
    
    IBOutlet UITableView* _tableView;
}

@property (nonatomic, retain) Radio* radio;
@property (nonatomic, assign) SongCatalog* catalog;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil usingCatalog:(SongCatalog*)catalog forRadio:(Radio*)radio;



@end
