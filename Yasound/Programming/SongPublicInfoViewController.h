//
//  SongPublicInfoViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 29/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
#import "WebImageView.h"



@interface SongPublicInfoViewController : UIViewController
{
    IBOutlet UIBarButtonItem* _backBtn;
    IBOutlet UILabel* _titleLabel;
    IBOutlet UITableView* _tableView;
    IBOutlet UIBarButtonItem* _nowPlayingButton;
    IBOutlet UIToolbar* _toolbar;
    
    WebImageView* _imageView;
    UILabel* _name;
    UILabel* _artist;
    UILabel* _album;

    BOOL _showNowPlaying;
    BOOL _ownSong;
    
    UILabel* _likesLabel;
}

@property (nonatomic, retain) Song* song;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil song:(Song*)aSong showNowPlaying:(BOOL)showNowPlaying;

- (IBAction)onBack:(id)sender;

@end
