//
//  ViewController.h
//  testFBConnect_And_TwitterConnect
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionManager.h"


@interface ViewController : UIViewController <SessionDelegate>
{
  IBOutlet UIBarButtonItem* _testBtn;
  
  IBOutlet UIButton* _facebookBtn;
  IBOutlet UIButton* _twitterBtn;
  IBOutlet UITextField* _login;
  IBOutlet UITextField* _password;  
}

@end
