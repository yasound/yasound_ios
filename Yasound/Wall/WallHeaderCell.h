
#import "UIKit/UIKit.h"
#import "WebImageView.h"
#import "Radio.h"

@interface WallHeaderCell : UITableViewCell

@property (nonatomic, retain) IBOutlet WebImageView* headerImage;
@property (nonatomic, retain) IBOutlet UILabel* headerTitle;
@property (nonatomic, retain) IBOutlet UILabel* headerSubscribers;
@property (nonatomic, retain) IBOutlet UILabel* headerListeners;
@property (nonatomic, retain) IBOutlet UILabel* headerButtonLabel;

- (void)setRadio:(Radio*)radio;
- (IBAction)onFavoriteClicked:(id)sender;

@end



//
////  WallViewController.h
////  Yasound
////
////  Copyright (c) 2011 Yasound. All rights reserved.
////
//
//#import <UIKit/UIKit.h>
//#import "WallMessage.h"
//#import "NowPlayingView.h"
////#import "TracksView.h"
//#import "SongViewCell.h"
//#import "TestflightViewController.h"
//#import "OrientedTableView.h"
//#import <MessageUI/MessageUI.h>
//#import "TouchedTableView.h"
//#import "RadioViewCell.h"
//#import "TopBar.h"
//
//
//@class Radio;
//@class AudioStreamer;
//@class WebImageView;
//
//@interface WallViewController : TestflightViewController<UITextInputDelegate, NSXMLParserDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UIActionSheetDelegate, UIScrollViewDelegate, MFMailComposeViewControllerDelegate,TopBarDelegate>
//{
//    //    NSAutoreleasePool* _ap;
//    
//    BOOL _updatingPrevious;
//    UILabel* _updatingPreviousLabel;
//    UIActivityIndicatorView* _updatingPreviousIndicator;
//    
//    UIView* _headerView;
//    BOOL _firstUpdateRequest;
//    
//    UILabel* _favoritesLabel;
//    BOOL _favoritesButtonLocked;
//    
//    UIImageView* _listenersIcon;
//    UILabel* _listenersLabel;
//    
//    TouchedTableView* _tableView;
//    
//    NowPlayingView* _playingNowView;
//    
//    WebImageView* _radioImage;
//    
//    UIView* _statusBar;
//    //    UIButton* _statusBarButton;
//    UIImageView* _statusBarButtonImage;
//    BOOL _statusBarButtonToggled;
//    
//    UIButton* _favoriteButton;
//    
//    UIView* _viewContainer;
//    UIPageControl* _pageControl;
//    
//    UIView* _viewWall;
//    //    TracksView* _viewTracks;
//    BOOL _viewTracksDisplayed;
//    
//    UITextField* _messageBar;
//    
//    WallEvent* _lastWallEvent;
//    WallEvent* _latestEvent;
//    
//    NSInteger _countMessageEvent;
//    NSDate* _lastSongUpdateDate;
//    
//    UIFont* _messageFont;
//    CGFloat _messageWidth;
//    CGFloat _cellMinHeight;
//    
//    NSTimer* _timerUpdate;
//    
//    NSMutableArray* _wallEvents;
//    BOOL _waitingForPreviousEvents;
//    
//    NSInteger _serverErrorCount;
//    
//    NSArray* _connectedUsers;
//    OrientedTableView* _usersContainer;
//    Radio* _radioForSelectedUser;
//    
//    UIActionSheet* _queryShare;
//    
//    RadioViewCell* _cellEditing;
//    NSLock* _updateLock;
//    
//    UIAlertView* _alertGoToRadio;
//    UIAlertView* _alertGoToLogin;
//}
//
//@property (nonatomic, retain) Radio* radio;
//@property (nonatomic) BOOL ownRadio;
//
//@property (atomic, retain) NSMutableArray* statusMessages;
//@property (nonatomic, retain) UIButton* favoriteButton;
//@property (nonatomic, retain) UIButton* playPauseButton;
//
//
//- (id)initWithRadio:(Radio*)radio;
//- (void)initRadioView;
//
//- (void)setNowPlaying:(NSString*)title artist:(NSString*)artist image:(UIImage*)image nbLikes:(NSInteger)nbLikes nbDislikes:(NSInteger)nbDislikes;
//- (void)setStatusMessage:(NSString*)message;
//
//- (void)addMessage;
//- (void)addSong;
//- (void)insertMessage;
//- (void)insertSong;
//
//
//
//@end
