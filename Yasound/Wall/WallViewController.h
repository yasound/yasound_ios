//
//  WallViewController.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WallMessage.h"
#import "SongViewCell.h"
#import "YaViewController.h"
#import "OrientedTableView.h"
#import <MessageUI/MessageUI.h>
#import "TouchedTableView.h"
#import "RadioViewCell.h"
#import "TopBar.h"
#import "WallHeaderCell.h"
#import "WallPostCell.h"

@class Radio;
@class AudioStreamer;
@class WebImageView;

@interface WallViewController : YaViewController<UITextInputDelegate, NSXMLParserDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UIActionSheetDelegate, UIScrollViewDelegate, MFMailComposeViewControllerDelegate,TopBarDelegate>
{
    BOOL _updatingPrevious;
    UILabel* _updatingPreviousLabel;
    UIActivityIndicatorView* _updatingPreviousIndicator;
    
    UIView* _headerView;
    BOOL _firstUpdateRequest;
    
    UIImageView* _listenersIcon;
    UILabel* _listenersLabel;
    
    WebImageView* _radioImage;
    
    UIView* _statusBar;
    UIImageView* _statusBarButtonImage;
    BOOL _statusBarButtonToggled;
    
    UIPageControl* _pageControl;
    
    BOOL _viewTracksDisplayed;
    
    WallEvent* _lastWallEvent;
    WallEvent* _latestEvent;
    
    NSInteger _countMessageEvent;
    NSDate* _lastSongUpdateDate;
    
    UIFont* _messageFont;
    CGFloat _messageWidth;
    CGFloat _cellMinHeight;
    
    NSTimer* _timerUpdate;
    
    NSMutableArray* _wallEvents;
    BOOL _waitingForPreviousEvents;
    
    NSInteger _serverErrorCount;
    
    UIActionSheet* _queryShare;
    
    RadioViewCell* _cellEditing;
    NSLock* _updateLock;
    
    UIAlertView* _alertGoToRadio;
    UIAlertView* _alertGoToLogin;
    
    UIActionSheet* _sheetTools;
    
    BOOL _stopWall;
}

@property (nonatomic, retain) Radio* radio;
@property (nonatomic) BOOL ownRadio;



@property (nonatomic, retain) NSMutableDictionary* requests;

@property (nonatomic) BOOL keyboardShown;
@property (nonatomic, retain) IBOutlet TopBar* topBar;

@property (nonatomic, retain) IBOutlet UIScrollView* nowPlayingScrollview;
@property (nonatomic, retain) IBOutlet WebImageView* nowPlayingTrackImage;
@property (nonatomic, retain) IBOutlet UIButton* nowPlayingMask;
@property (nonatomic, retain) IBOutlet UIButton* nowPlayingButton;
@property (nonatomic, retain) IBOutlet UILabel* nowPlayingLabel1;
@property (nonatomic, retain) IBOutlet UILabel* nowPlayingLabel2;
@property (nonatomic, retain) IBOutlet UIButton* nowPlayingShare;
@property (nonatomic, retain) IBOutlet UIButton* nowPlayingLike;
@property (nonatomic, retain) IBOutlet UIButton* nowPlayingBuy;



@property (nonatomic, retain) IBOutlet TouchedTableView* tableview;
@property (nonatomic, retain) IBOutlet WallHeaderCell* cellWallHeader;

@property (nonatomic, retain) IBOutlet WallPostCell* fixedCellPostBar;
@property (nonatomic, retain) IBOutlet WallPostCell* cellPostBar;


@property (atomic, retain) NSMutableArray* statusMessages;



- (id)initWithRadio:(Radio*)radio;
- (void)initRadioView;

- (void)setStatusMessage:(NSString*)message;

- (void)addMessage;
- (void)addSong;
- (void)insertMessage;
- (void)insertSong;

- (IBAction)onPostBarButtonClicked:(id)sender;




@end
