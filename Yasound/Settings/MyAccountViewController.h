//
//  MyAccountViewController.h
//  Yasound
//
//  Created by neywen on 07/08/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopBarModal.h"
#import "User.h"
#import "DateViewController.h"
#import "GenderPickerViewController.h"
#import "WebImageView.h"
#import "BioViewController.h"

@interface MyAccountViewController : YaViewController<TopBarModalDelegate,UITextFieldDelegate,DateViewDelegate,GenderPickerDelegate,BioDelegate>
{
    BOOL _changed;
    BOOL _imageChanged;
    UIActionSheet* _pickImageQuery;
}

@property (nonatomic, retain) IBOutlet TopBarModal* topbar;


@property (nonatomic, retain) User* user;
@property (nonatomic, retain) IBOutlet UITableView* tableview;
@property (nonatomic, retain) UITextField* username;
@property (nonatomic, retain) WebImageView* userImage;
@property (nonatomic, retain) UITextField* city;
@property (nonatomic, retain) UILabel* age;

//@property (nonatomic) TopBarItemId itemId;


@end
