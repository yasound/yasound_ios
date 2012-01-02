//
//  LegalViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 21/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyTracker.h"


@interface LegalViewController : TrackedUIViewController
{
    BOOL _wizard;
    
    IBOutlet UIToolbar* _toolbar;
    IBOutlet UIBarButtonItem* _backBtn;
    IBOutlet UILabel* _titleLabel;
    UIBarButtonItem* _nextBtn;
    
    IBOutlet UITableView* _tableView;  
    IBOutlet UITableViewCell* _cellAgreement;
    IBOutlet UILabel* _cellAgreementLabel;
}

- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil wizard:(BOOL)wizard;


- (IBAction)onBack:(id)sender;
- (IBAction)onNext:(id)sender;

@end
