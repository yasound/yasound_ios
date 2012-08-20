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

@property (nonatomic, retain) NSArray* radios;
@property (nonatomic, retain) NSArray* favorites;
@property (nonatomic, retain) NSArray* friends;

@property (nonatomic, retain) IBOutlet UITableView* tableview;
@property (nonatomic, retain) IBOutlet TabBar* tabBar;


@property (nonatomic, retain) User* user;
@property (nonatomic, retain) NSNumber* userId;
@property (nonatomic, retain) NSString* modelUsername;
@property (nonatomic) BOOL followed;

@property (nonatomic, retain) IBOutlet UITableViewCell* cellProfil;

@property (nonatomic, retain) IBOutlet WebImageView* userImage;
@property (nonatomic, retain) IBOutlet UILabel* name;
@property (nonatomic, retain) IBOutlet UILabel* profil;
@property (nonatomic, retain) IBOutlet UIImageView* hd;

@property (nonatomic, retain) IBOutlet UIButton* buttonGray;
@property (nonatomic, retain) IBOutlet UILabel* buttonGrayLabel;
@property (nonatomic, retain) IBOutlet UIButton* buttonBlue;
@property (nonatomic, retain) IBOutlet UILabel* buttonBlueLabel;


- (IBAction)onButtonGrayClicked:(id)sender;
- (IBAction)onButtonBlueClicked:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forUser:(User*)user;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withUserId:(NSNumber*)numberId;

@end
