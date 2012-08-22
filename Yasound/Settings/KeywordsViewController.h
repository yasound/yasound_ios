//
//  KeywordsViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 21/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "YasoundDataProvider.h"
#import "YaViewController.h"



@interface KeywordsViewController : YaViewController
{
    Radio* _myRadio;
    
    IBOutlet UIBarButtonItem* _backBtn;
    IBOutlet UIBarButtonItem* _editBtn;
    IBOutlet UIToolbar* _toolbar;
    IBOutlet UILabel* _titleLabel;
    
    IBOutlet UITableView* _tableView;
    
//    IBOutlet UITableViewCell* _cellAdd;
//    IBOutlet UILabel* _cellAddLabel;
    
    IBOutlet UITableViewCell* _cellTextField;
    IBOutlet UITextField* _textField;
    
    NSMutableArray* _keywords;
    BOOL _firstRowIsNotValidated;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil radio:(Radio*)radio;


@end
