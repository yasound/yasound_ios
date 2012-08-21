//
//  WebPageViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 21/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YaViewController.h"


@interface WebPageViewController : YaViewController
{
    IBOutlet UIToolbar* _toolbar;
    IBOutlet UIBarButtonItem* _backBtn;
    IBOutlet UILabel* _titleLabel;
    IBOutlet UIWebView* _webview;
}

@property (nonatomic, retain) NSURL* url;

- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil withUrl:(NSURL*)url andTitle:(NSString*)title;


- (IBAction)onBack:(id)sender;
- (IBAction)onNext:(id)sender;


@end
