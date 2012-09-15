//
//  TwitterSigninViewController.h
//  testFBConnect_And_TwitterConnect
//
//  Created by LOIC BERTHELOT on 16/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwitterSigninViewController : YaViewController
{
  IBOutlet UITableView* _tableView;
  IBOutlet UITableViewCell* _login;
  IBOutlet UITableViewCell* _password;
  IBOutlet UITableViewCell* _signin;
  
}

@end
