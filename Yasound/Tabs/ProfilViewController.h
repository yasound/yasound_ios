//
//  ProfilViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBar.h"
#import "TopBar.h"
#import "WebImageView.h"
#import "User.h"

@interface ProfilViewController : UIViewController<TopBarDelegate, TabBarDelegate>

@property (nonatomic, retain) IBOutlet UITableViewCell* cellProfil;

@property (nonatomic, retain) User* user;

@property (nonatomic, retain) IBOutlet WebImageView* userImage;
@property (nonatomic, retain) IBOutlet UILabel* name;
@property (nonatomic, retain) IBOutlet UILabel* bio;
@property (nonatomic, retain) IBOutlet UIImageView* hd;

@property (nonatomic, retain) IBOutlet UILabel* buttonGrayLabel;
@property (nonatomic, retain) IBOutlet UILabel* buttonBlueLabel;

@property (nonatomic, retain) IBOutlet TabBar* tabBar;

- (IBAction)onButtonGrayClicked:(id)sender;
- (IBAction)onButtonBlueClicked:(id)sender;

@end
