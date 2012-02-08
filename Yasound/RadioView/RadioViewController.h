//
//  RadioViewController.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WallMessage.h"
#import "NowPlayingView.h"
#import "TracksView.h"
#import "SongViewCell.h"
#import "TestflightViewController.h"
#import "OrientedTableView.h"

@class Radio;
@class AudioStreamer;
@class WebImageView;

@interface RadioViewController : TestflightViewController<UITextInputDelegate, NSXMLParserDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSDate* _BEGIN;
    NSDate* _END;
    
    BOOL _updatingPrevious;
    UILabel* _updatingPreviousLabel;
    UIActivityIndicatorView* _updatingPreviousIndicator;
    
    UIView* _headerView;
    BOOL _firstUpdateRequest;
    
    UILabel* _favoritesLabel;
    
    UIImageView* _listenersIcon;
    UILabel* _listenersLabel;
  
    UITableView* _tableView;
    
    NowPlayingView* _playingNowView;
    
    WebImageView* _radioImage;
    
    UIView* _statusBar;
    UIButton* _statusBarButton;
    BOOL _statusBarButtonToggled;
    
    UIButton* _favoriteButton;
    
    UIView* _viewContainer;
    UIPageControl* _pageControl;
    
    UIView* _viewWall;
    TracksView* _viewTracks;
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
    
    NSInteger _serverErrorCount;
    NSInteger _streamErrorCount;
  
  NSArray* _connectedUsers;
  OrientedTableView* _usersContainer;
}

@property (nonatomic, retain) Radio* radio;
@property (nonatomic) BOOL ownRadio;
@property (atomic, retain) NSMutableArray* statusMessages;
@property (nonatomic, retain) UIButton* favoriteButton;

- (id)initWithRadio:(Radio*)radio;
- (void)initRadioView;

- (void)setNowPlaying:(NSString*)title artist:(NSString*)artist image:(UIImage*)image nbLikes:(NSInteger)nbLikes nbDislikes:(NSInteger)nbDislikes;
- (void)setStatusMessage:(NSString*)message;

- (void)addMessage;
- (void)addSong;
- (void)insertMessage;
- (void)insertSong;
                        


@end
