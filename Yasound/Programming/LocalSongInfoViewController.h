//
//  LocalSongInfoViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 29/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
#import "WebImageView.h"



@interface LocalSongInfoViewController : UIViewController
{
    IBOutlet UIBarButtonItem* _backBtn;
    IBOutlet UILabel* _titleLabel;
    IBOutlet UITableView* _tableView;
    IBOutlet UIBarButtonItem* _nowPlayingButton;

    WebImageView* _imageView;
    UILabel* _name;
    UILabel* _artist;
    UILabel* _album;

    UISwitch* _switchFrequency;

}

@property (nonatomic, retain) Song* song;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil song:(Song*)aSong;

- (IBAction)onBack:(id)sender;

@end
