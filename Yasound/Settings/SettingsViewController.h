//
//  SettingsViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 21/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyTracker.h"


@interface SettingsViewController : TrackedUIViewController
{
    IBOutlet UITableView* _tableView;  

    IBOutlet UITableViewCell* _settingsTitleCell;
    IBOutlet UILabel* _settingsTitleLabel;
    IBOutlet UITextField* _settingsTitleTextField;
    
    IBOutlet UITableViewCell* _settingsImageCell;
    IBOutlet UILabel* _settingsImageLabel;
    IBOutlet UIImageView* _settingsImageImage;
    
    IBOutlet UITableViewCell* _settingsThemeCell;
    IBOutlet UILabel* _settingsThemeTitle;
    IBOutlet UIImageView* _settingsThemeImage;
    
    NSString* _keywords;

}


@end
