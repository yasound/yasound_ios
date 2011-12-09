//
//  RadioViewController.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@class Radio;
@class AudioStreamer;


@interface RadioViewController : UIViewController<UITextInputDelegate, NSXMLParserDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UITableView* _tableView;
    
    UIView* _playingNowContainer;
    UIView* _playingNowView;
    
    UIView* _statusBar;
    UIButton* _statusBarButton;
    BOOL _statusBarButtonToggled;
    UIScrollView* _statusUsers;

    Message* _currentMessage;
    NSMutableString* _currentXMLString;
    
    UIFont* _messageFont;
    CGFloat _messageWidth;
    CGFloat _cellMinHeight;
    
    NSTimer* _timerUpdate;
    NSTimer* _timerFake;
}

@property (nonatomic, retain) Radio* radio;
@property (nonatomic, retain) NSMutableArray* messages;
@property (atomic, retain) NSMutableArray* statusMessages;

@property (nonatomic, retain) AudioStreamer* audioStreamer;



- (void)setNowPlaying:(NSString*)title artist:(NSString*)artist image:(UIImage*)image nbLikes:(NSInteger)nbLikes nbDislikes:(NSInteger)nbDislikes;
- (void)addMessage:(NSString*)text user:(NSString*)user avatar:(UIImage*)avatar date:(NSString*)date silent:(BOOL)silent;
- (void)setStatusMessage:(NSString*)message;


@end
