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
  IBOutlet UITextView* _textView;
  
  BOOL _facebookBtnClicked;
  BOOL _twitterBtnClicked;
}

- (void)log:(NSString*)str;
- (void)logClear;


- (IBAction)onLogoutClicked:(id)sender;
- (IBAction)onTestClicked:(id)sender;
- (IBAction)onFacebookConnect:(id)sender;
- (IBAction)onTwitterConnect:(id)sender;
- (IBAction)onUsernameClicked:(id)sender;
- (IBAction)onFriendsClicked:(id)sender;
- (IBAction)onFollowersClicked:(id)sender;
- (IBAction)onPostMessageClicked:(id)sender;
- (IBAction)onClearClicked:(id)sender;



@end
