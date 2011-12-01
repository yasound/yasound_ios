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

    Message* _currentMessage;
    NSMutableString* _currentXMLString;
}

@property (nonatomic, retain) NSMutableArray* messages;

@end
