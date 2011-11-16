//
//  TwitteriOSManager.h
//  iOS twitter account manager
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import "TwitterAccountsViewController.h"






@interface TwitteriOSManager : NSObject <TwitterAccountsDelegate>
{
  ACAccount* _twitterAccount;
}

@property (retain) ACAccount* twitterAccount;



@end
