//
//  PlaylistsViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 21/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YaViewController.h"
#import "SongsViewController.h"
#import "TopBarSaveOrCancel.h"
#import "YaRadio.h"

typedef enum {
    eDisplayModeNormal = 0,
    eDisplayModeEdit = 1,
} DisplayMode;


@interface PlaylistsViewController : YaViewController<TopBarSaveOrCancelDelegate>
{
    BOOL _changed;
    
    IBOutlet UIView* _container;

    IBOutlet UITableView* _tableView;

    NSArray* _playlists;                   // NSArray of MPMediaPlaylist*
    NSArray* _songs;                       // NSArray of MPMediaItem*
    NSMutableArray* _playlistsDesc;        // NSArray of NSDictionary {name, count}
    NSMutableArray* _selectedPlaylists;    // NSMutableArray of Dictionary
    NSMutableArray* _unselectedPlaylists;  // NSMutableArray of Dictionary
    NSMutableArray* _localPlaylistsDesc;
    
    DisplayMode _displayMode;
    SongsViewController *_songsViewController;
    
    UIImage* _checkmarkImage;
    UIImage* _checkmarkDisabledImage;
    
    UIAlertView* _alertMatchedSongs;
    UIAlertView* _alertSubmitError;
    
    UISwitch* _switchAllMyMusic;
}

@property (nonatomic, retain) YaRadio* radio;

@property (nonatomic, retain) IBOutlet TopBarSaveOrCancel* topbar;

@property (nonatomic) NSInteger nbPlaylistsForChecking;
@property (nonatomic) NSInteger nbParsedPlaylistsForChecking;
@property (nonatomic) NSInteger nbMatchedSongs;
@property (nonatomic, retain) NSData* playlistsDataPackage;
@property (nonatomic, retain) NSTimer* taskTimer;
@property (nonatomic) BOOL createMode;


- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil wizard:(BOOL)wizard;
- (void) refreshView;
- (IBAction)onBack:(id)sender;
- (IBAction)onNext:(id)sender;
- (IBAction)onEdit:(id)sender;

@end
