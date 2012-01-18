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

@class Radio;
@class AudioStreamer;
@class WebImageView;

@interface RadioViewController : UIViewController<UITextInputDelegate, NSXMLParserDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UIView* _headerView;
  
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

    NSDate* _lastWallEventDate;
    NSDate* _lastConnectionUpdateDate;
    NSDate* _lastSongUpdateDate;
  
    WallMessage* _currentMessage;
    NSMutableString* _currentXMLString;
    
    UIFont* _messageFont;
    CGFloat _messageWidth;
    CGFloat _cellMinHeight;
    
    NSTimer* _timerUpdate;
    
    NSMutableArray* _wallEvents;
}

@property (nonatomic, retain) Radio* radio;
@property (nonatomic) BOOL ownRadio;
@property (nonatomic, retain) NSMutableArray* messages;
@property (atomic, retain) NSMutableArray* statusMessages;
@property (nonatomic, retain) UIButton* favoriteButton;

- (id)initWithRadio:(Radio*)radio;
- (void)initRadioView;

- (void)setNowPlaying:(NSString*)title artist:(NSString*)artist image:(UIImage*)image nbLikes:(NSInteger)nbLikes nbDislikes:(NSInteger)nbDislikes;
- (void)addMessage:(NSString*)text user:(NSString*)user avatar:(NSURL*)avatarURL date:(NSDate*)date silent:(BOOL)silent;
- (void)addSong:(NSInteger)index;
- (void)setStatusMessage:(NSString*)message;


@end
