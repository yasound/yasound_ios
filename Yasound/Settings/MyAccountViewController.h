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


@interface MyAccountViewController : UIViewController<TopBarDelegate,UITextFieldDelegate,DateViewDelegate>

@property (nonatomic, retain) User* user;
@property (nonatomic, retain) IBOutlet UITableView* tableview;


@end
