//
//  LegalViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 21/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestflightViewController.h"


@interface LegalViewController : TestflightViewController
{
    IBOutlet UIToolbar* _toolbar;
    IBOutlet UIBarButtonItem* _backBtn;
    IBOutlet UILabel* _titleLabel;
    
    IBOutlet UITableView* _tableView;  
//    IBOutlet UITableViewCell* _cellAgreement;
//    IBOutlet UILabel* _cellAgreementLabel;
    
    NSString* _legalText;
    UIFont* _legalFont;
    UILabel* _legalLabel;
}


- (IBAction)onBack:(id)sender;
- (IBAction)onNext:(id)sender;


@end
