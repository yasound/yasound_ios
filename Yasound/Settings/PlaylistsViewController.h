//
//  PlaylistsViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 21/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestflightViewController.h"
#import "SongsViewController.h"
typedef enum {
    eDisplayModeNormal = 0,
    eDisplayModeEdit = 1,
} DisplayMode;


@interface PlaylistsViewController : TestflightViewController
{
    BOOL _wizard;
    BOOL _changed;
    BOOL _forceEnableNextBtn;
    
    IBOutlet UIView* _container;

    IBOutlet UIToolbar* _toolbar;
    IBOutlet UIBarButtonItem* _backBtn;
    IBOutlet UILabel* _titleLabel;
    UIBarButtonItem* _nextBtn;
    
    IBOutlet UITableView* _tableView;  
    CGFloat _cellHowtoHeight;
    NSString* _howto; 

    IBOutlet UIView* _itunesConnectView;
    IBOutlet UILabel* _itunesConnectLabel;

    NSArray* _playlists;                   // NSArray of MPMediaPlaylist*
    NSMutableArray* _playlistsDesc;        // NSArray of NSDictionary {name, count}
    NSMutableArray* _selectedPlaylists;    // NSMutableArray of Dictionary
    NSMutableArray* _unselectedPlaylists;  // NSMutableArray of Dictionary
    NSMutableArray* _remotePlaylistsDesc;
    NSMutableArray* _localPlaylistsDesc;
    
    NSTimer* taskTimer;
    DisplayMode _displayMode;
    SongsViewController *_songsViewController;
    
    UIImage* _checkmarkImage;
    
    UIAlertView* _alertMatchedSongs;
    UIAlertView* _alertSubmitError;
}

@property (nonatomic) NSInteger nbPlaylistsForChecking;
@property (nonatomic) NSInteger nbParsedPlaylistsForChecking;
@property (nonatomic) NSInteger nbMatchedSongs;
@property (nonatomic, retain) NSData* playlistsDataPackage;

- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil wizard:(BOOL)wizard;
- (void) refreshView;
- (IBAction)onBack:(id)sender;
- (IBAction)onNext:(id)sender;
- (IBAction)onEdit:(id)sender;

@end
