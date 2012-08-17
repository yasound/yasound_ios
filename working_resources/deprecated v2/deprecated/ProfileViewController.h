//
//  ProfileViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 29/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "WebImageView.h"



@interface ProfileViewController : UIViewController
{
    IBOutlet UIBarButtonItem* _backBtn;
    IBOutlet UIBarButtonItem* _titleLabel;
    IBOutlet UITableView* _tableView;
    IBOutlet UIBarButtonItem* _nowPlayingButton;
    
    WebImageView* _imageView;
    NSArray* _favoriteRadios;
    UILabel* _name;
}

@property (nonatomic, retain) User* user;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User*)aUser;

- (IBAction)onBack:(id)sender;

@end
