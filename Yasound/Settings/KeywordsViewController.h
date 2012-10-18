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
#import "TopBarBackAndTitle.h"


@protocol KeywordsDelegate
- (void)onKeywordsChanged:(NSArray*)keywords;
@end


@interface KeywordsViewController : YaViewController
{
    Radio* _myRadio;
    
    IBOutlet UIBarButtonItem* _editBtn;
    
    IBOutlet UITableView* _tableView;
    
    IBOutlet UITableViewCell* _cellTextField;
    IBOutlet UITextField* _textField;
    
    NSMutableArray* _keywords;
    BOOL _firstRowIsNotValidated;
}

@property (nonatomic, retain) IBOutlet TopBarBackAndTitle* topbar;
@property (nonatomic, assign) id<KeywordsDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil radio:(Radio*)radio;


@end
