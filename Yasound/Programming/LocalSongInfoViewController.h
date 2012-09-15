//
//  LocalSongInfoViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 29/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongLocal.h"



@interface LocalSongInfoViewController : YaViewController
{
//    IBOutlet UIBarButtonItem* _backBtn;
//    IBOutlet UILabel* _titleLabel;
    IBOutlet UITableView* _tableView;
//    IBOutlet UIBarButtonItem* _nowPlayingButton;
    
    IBOutlet UITableViewCell* _cellDelete;
    IBOutlet UILabel* _cellDeleteLabel;
    IBOutlet UIToolbar* _toolbar;

    UIImageView* _imageView;
    UILabel* _name;
    UILabel* _artist;
    UILabel* _album;

}

@property (nonatomic, retain) SongLocal* song;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil song:(SongLocal*)aSong;

- (IBAction)onBack:(id)sender;

@end
