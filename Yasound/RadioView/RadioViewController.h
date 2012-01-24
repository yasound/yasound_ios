//
//  RadioViewController.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WallMessage.h"
#import "NowPlayingView.h"
#import "TrackInteractionView.h"
#import "TracksView.h"
#import "SongViewCell.h"

@class Radio;
@class AudioStreamer;
@class WebImageView;

@interface RadioViewController : UIViewController<UITextInputDelegate, NSXMLParserDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UIView* _headerView;
    
    UILabel* _favoritesLabel;
    UILabel* _listenersLabel;
  
    UITableView* _tableView;
    
    UIView* _playingNowContainer;
    NowPlayingView* _playingNowView;
    TrackInteractionView* _trackInteractionView;
    BOOL _trackInteractionViewDisplayed;
    
    WebImageView* _radioImage;
    
    UIView* _statusBar;
    UIButton* _statusBarButton;
    BOOL _statusBarButtonToggled;
    UIScrollView* _statusUsers;
    
    UIButton* _favoriteButton;
    
    UIView* _viewContainer;
    UIPageControl* _pageControl;
    
    UIView* _viewWall;
    TracksView* _viewTracks;
    BOOL _viewTracksDisplayed;

    WallEvent* _lastWallEvent;
    WallEvent* _latestSongContainer;
    WallEvent* _latestEvent;
    
    NSInteger _countMessageEvent;
    NSDate* _lastSongUpdateDate;
  
    UIFont* _messageFont;
    CGFloat _messageWidth;
    CGFloat _cellMinHeight;
    
    NSTimer* _timerUpdate;
    
    NSMutableArray* _wallEvents;
}

@property (nonatomic, retain) Radio* radio;
@property (nonatomic) BOOL ownRadio;
//@property (nonatomic, retain) NSMutableArray* messages;
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
