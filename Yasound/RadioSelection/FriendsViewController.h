//
//  FriendsViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 18/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyTracker.h"

@interface FriendsViewController : TrackedUIViewController
{
    IBOutlet UIToolbar* _toolbar;
    IBOutlet UILabel* _toolbarTitle;
    IBOutlet UIBarButtonItem* _nowPlayingButton;
    
    IBOutlet UITableView* _tableView;
    
    NSArray* _friends_online;
    NSArray* _friends_offline;
}


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabIcon:(NSString*)tabIcon;

- (IBAction)menuBarItemClicked:(id)sender;


@end

