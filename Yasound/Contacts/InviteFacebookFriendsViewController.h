//
//  InviteFacebookFriendsViewController.h
//  Yasound
//
//  Created by mat on 25/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopBarModal.h"
#import "FacebookSessionManager.h"
#import "WaitingView.h"

@interface InviteFacebookFriendsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, TopBarModalDelegate, SessionDelegate>
{
    IBOutlet UITableView* _tableview;
    
    NSArray* _friends;
    NSMutableSet* _selectedFriends;
    
    UIImage* _checkmarkImage;
    
    WaitingView* _waitingView;
}

@end
