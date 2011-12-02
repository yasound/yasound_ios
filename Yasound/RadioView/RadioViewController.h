//
//  RadioViewController.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"


@interface RadioViewController : UIViewController<UITextInputDelegate, NSXMLParserDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UITableView* _tableView;
    UIView* _statusBar;
    UIButton* _statusBarButton;
    BOOL _statusBarButtonToggled;

    Message* _currentMessage;
    NSMutableString* _currentXMLString;
    
    UIFont* _messageFont;
    CGFloat _messageWidth;
    CGFloat _cellMinHeight;
}

@property (nonatomic, retain) NSMutableArray* messages;

@property (atomic, retain) NSMutableArray* statusMessages;

@end
