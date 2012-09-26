//
//  InviteContactsViewController.h
//  Yasound
//
//  Created by mat on 24/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopBarModal.h"
#import "Contact.h"

@interface InviteContactsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, TopBarModalDelegate>
{
    NSArray* _contacts;
    NSMutableSet* _selectedContacts;
    
    IBOutlet UITableView* _tableview;
    IBOutlet UILabel* _accessNotGrantedLabel;
    
    UIImage* _checkmarkImage;
    
    BOOL _accessGranted;
}


@end
