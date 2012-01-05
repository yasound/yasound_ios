//
//  SettingsViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 21/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyTracker.h"
#import "YasoundDataProvider.h"


@interface SettingsViewController : TrackedUIViewController
{
    BOOL _wizard;
    BOOL _changed;
    Radio* _radio;
    
    UIActionSheet* _saveQuery;
    UIActionSheet* _pickImageQuery;

    
    IBOutlet UIView* _container;
    
    IBOutlet UIToolbar* _toolbar;
    IBOutlet UIBarButtonItem* _backBtn;
    IBOutlet UILabel* _titleLabel;
    UIBarButtonItem* _nextBtn;

    
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

- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil wizard:(BOOL)wizard radio:(Radio*)radio;


@end
