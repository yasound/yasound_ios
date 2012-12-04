//
//  SettingsViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 21/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YaViewController.h"
#import "YasoundDataProvider.h"
#import "WebImageView.h"
#import "TopBarSaveOrCancel.h"

@interface SettingsViewController : YaViewController<TopBarSaveOrCancelDelegate>
{
    BOOL _changed;
    
    UIActionSheet* _pickImageQuery;
        
    IBOutlet UITableView* _tableView;  

    IBOutlet UITableViewCell* _settingsTitleCell;
    IBOutlet UILabel* _settingsTitleLabel;
    IBOutlet UITextField* _settingsTitleTextField;
    
    IBOutlet UITableViewCell* _settingsImageCell;
    IBOutlet UILabel* _settingsImageLabel;
    IBOutlet WebImageView* _settingsImageImage;
    BOOL _settingsImageChanged;
    
    NSString* _keywords;

}

@property (nonatomic, retain) YaRadio* radioBackup;
@property (nonatomic, retain) IBOutlet TopBarSaveOrCancel* topbar;
@property (nonatomic, retain) YaRadio* radio;
@property (nonatomic) BOOL createMode;



- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil forRadio:(YaRadio*)radio createMode:(BOOL)createMode;


@end
