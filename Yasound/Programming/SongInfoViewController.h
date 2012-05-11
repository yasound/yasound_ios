//
//  SongInfoViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 29/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
#import "WebImageView.h"



@interface SongInfoViewController : UIViewController
{
    IBOutlet UIBarButtonItem* _backBtn;
    IBOutlet UILabel* _titleLabel;
    IBOutlet UITableView* _tableView;
    IBOutlet UIBarButtonItem* _nowPlayingButton;
    IBOutlet UIToolbar* _toolbar;
    
    IBOutlet UITableViewCell* _cellDelete;
    IBOutlet UILabel* _cellDeleteLabel;

    WebImageView* _imageView;
    UILabel* _name;
    UILabel* _artist;
    UILabel* _album;
//    UILabel* _enabledLabel;

    UISwitch* _switchEnabled;
    UISwitch* _switchFrequency;
    
    BOOL _showNowPlaying;
    
    UIAlertView* _alertReject;
    UIAlertView* _alertUpload;
    UIAlertView* _alertUploading;

}

@property (nonatomic, retain) Song* song;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil song:(Song*)aSong showNowPlaying:(BOOL)showNowPlaying;

- (IBAction)onBack:(id)sender;

@end
