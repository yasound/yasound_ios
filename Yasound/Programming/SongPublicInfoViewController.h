//
//  SongPublicInfoViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 29/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
#import "Radio.h"
#import "WebImageView.h"



@interface SongPublicInfoViewController : YaViewController
{
    IBOutlet UITableView* _tableView;
    IBOutlet UIToolbar* _toolbar;
    
    WebImageView* _imageView;
    UILabel* _name;
    UILabel* _artist;
    UILabel* _album;

    BOOL _showNowPlaying;
    BOOL _ownSong;
    
    UILabel* _likesLabel;
    UIActionSheet* _queryShare;
}

@property (nonatomic, retain) Song* song;
@property (nonatomic, retain) Radio* radio;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil song:(Song*)aSong onRadio:(Radio*)aRadio showNowPlaying:(BOOL)showNowPlaying;

- (IBAction)onBack:(id)sender;

@end
