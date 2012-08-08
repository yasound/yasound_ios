//
//  MyAccountViewController.h
//  Yasound
//
//  Created by neywen on 07/08/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopBar.h"
#import "User.h"
#import "DateViewController.h"
#import "GenderPickerViewController.h"
#import "WebImageView.h"
#import "BioViewController.h"

@interface MyAccountViewController : UIViewController<TopBarDelegate,UITextFieldDelegate,DateViewDelegate,GenderPickerDelegate,BioDelegate>
{
    BOOL _changed;
    BOOL _imageChanged;
    UIActionSheet* _pickImageQuery;
}


@property (nonatomic, retain) User* user;
@property (nonatomic, retain) IBOutlet UITableView* tableview;
@property (nonatomic, retain) UITextField* username;
@property (nonatomic, retain) WebImageView* userImage;
@property (nonatomic, retain) UITextField* city;
@property (nonatomic, retain) UILabel* age;


@end
