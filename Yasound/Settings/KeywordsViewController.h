//
//  KeywordsViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 21/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface KeywordsViewController : UIViewController
{
    IBOutlet UITableView* _tableView;
    IBOutlet UITableViewCell* _cellTextField;
    IBOutlet UITextField* _textField;
    
    NSMutableArray* _keywords;
    BOOL _firstRowIsNotValidated;
}



@end
