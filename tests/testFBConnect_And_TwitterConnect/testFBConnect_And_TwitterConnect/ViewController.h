//
//  ViewController.h
//  testFBConnect_And_TwitterConnect
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SA_OAuthTwitterController.h" 
#import "SA_OAuthTwitterEngine.h"

@interface ViewController : UIViewController
{
  IBOutlet UIButton* _facebookBtn;
  IBOutlet UIButton* _twitterBtn;
  IBOutlet UITextField* _login;
  IBOutlet UITextField* _password;
  
  SA_OAuthTwitterEngine    *_engine; 
}

@property BOOL facebookConnected;
@property BOOL twitterConnected;

@end
