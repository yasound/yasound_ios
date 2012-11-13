//
//  MessageWebViewController.h
//  Yasound
//
//  Created by matthieu campion on 4/5/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageWebViewController : YaViewController
{
  NSString* _url;
  
  IBOutlet UIBarButtonItem* _nowPlayingButton;
  IBOutlet UIWebView* _webView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSString*)url;

- (IBAction)onNowPlayingClicked:(id)sender;
- (IBAction)onMenuBarItemClicked:(id)sender;

@end
