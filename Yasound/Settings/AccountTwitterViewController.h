//
//  AccountTwitterViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 30/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountTwitterViewController : UIViewController
{
    IBOutlet UIBarButtonItem* _backItem;
    IBOutlet UIBarButtonItem* _titleItem;
    
    IBOutlet UILabel* _usernameLabel;
    IBOutlet UILabel* _usernameValue;
    IBOutlet UILabel* _logoutLabel;
    
}

- (IBAction)onBack:(id)sender;
- (IBAction)onButtonClicked:(id)sender;


@end
