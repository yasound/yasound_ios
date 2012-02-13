//
//  FriendsViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 18/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestflightViewController.h"

@interface FriendsViewController : TestflightViewController
{
    IBOutlet UIToolbar* _toolbar;
    IBOutlet UILabel* _toolbarTitle;
    IBOutlet UIBarButtonItem* _nowPlayingButton;
    
    IBOutlet UITableView* _tableView;
    
    IBOutlet UITableViewCell* _cellInvite;
    IBOutlet UILabel* _cellInviteLabel;
    
    NSMutableArray* _friends_online;
    NSMutableArray* _friends_offline;
}


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabIcon:(NSString*)tabIcon;

- (IBAction)menuBarItemClicked:(id)sender;
- (IBAction)inviteButtonClicked:(id)sender;


@end

