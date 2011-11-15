//
//  TwitterAccountsViewController.h
//  testFBConnect_And_TwitterConnect
//
//  Created by LOIC BERTHELOT on 15/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@interface TwitterAccountsViewController : UIViewController
{
  IBOutlet UITableView* _tableView;
  
  ACAccountStore* _accountStore; 
  NSArray* _accounts;
  
}

@property (strong, nonatomic) ACAccountStore* accountStore; 
@property (strong, nonatomic) NSArray* accounts;

@end
