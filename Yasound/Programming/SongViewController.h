//
//  SongViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
#import "RCSwitchClone.h"

@interface SongViewController : UIViewController
{
    IBOutlet UIBarButtonItem* _backBtn;
    IBOutlet UILabel* _titleLabel;
    IBOutlet UITableView* _tableView;
    
    UISwitch* _switchEnabled;
    UISwitch* _switchFrequency;
}

@property (nonatomic, retain) Song* song;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil song:(Song*)song;

@end
