//
//  TwitterAccountsViewController.h
//  testFBConnect_And_TwitterConnect
//
//  Created by LOIC BERTHELOT on 15/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@class TwitterAccountsViewController;

@protocol TwitterAccountsDelegate <NSObject>
@required
- (void)twitterDidSelectAccount:(ACAccount*)account;
@end



@interface TwitterAccountsViewController : UIViewController
{
  IBOutlet UITableView* _tableView;
//  NSArray* _accounts;
}

//@property (strong, nonatomic) ACAccountStore* accountStore; 
@property (strong, nonatomic) NSArray* accounts;
@property (retain) id<TwitterAccountsDelegate> delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil accounts:(NSArray*)accounts target:(id)target;



@end
