//
//  TwitteriOSSessionManager.h
//  iOS twitter session manager
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionManager.h"
#import <Accounts/Accounts.h>
#import "TwitterAccountsViewController.h"



@interface TwitteriOSSessionManager : SessionManager <TwitterAccountsDelegate>
{
  ACAccount* _account;
  NSArray* _accounts;
}

@property (retain) ACAccountStore* store;
@property (retain) ACAccount* account;
@property (retain) NSArray* accounts;


- (void)login:(UIViewController*)target;
- (void)logout;



@end
