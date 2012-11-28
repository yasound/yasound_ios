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
#import "YasoundRadio.h"


@interface SongInfoViewController : YaViewController
{
    IBOutlet UITableView* _tableView;

    WebImageView* _imageView;
    UILabel* _name;
    UILabel* _artist;
    UILabel* _album;

    UISwitch* _switchEnabled;
    UISwitch* _switchFrequency;
    
    BOOL _showNowPlaying;
    BOOL _ownSong;
    
    UIAlertView* _alertReject;
    UIAlertView* _alertUpload;
    UIAlertView* _alertUploading;

}

@property (nonatomic, retain) Song* song;
@property (nonatomic, retain) YasoundRadio* radio;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil song:(Song*)aSong showNowPlaying:(BOOL)showNowPlaying forRadio:(YasoundRadio*)radio;

- (IBAction)onBack:(id)sender;

@end
