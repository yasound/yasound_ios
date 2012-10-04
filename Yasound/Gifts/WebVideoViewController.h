//
//  WebVideoViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 21/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YaViewController.h"
#import "TopBarModal.h"

@interface WebVideoViewController : YaViewController
{
    IBOutlet TopBarModal* _toolbar;
    IBOutlet UIBarButtonItem* _backBtn;
    IBOutlet UILabel* _titleLabel;
    IBOutlet UIWebView* _webview;
}

@property (nonatomic, retain) NSURL* videoUrl;

- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil withVideoUrl:(NSURL*)url;


- (IBAction)onBack:(id)sender;
- (IBAction)onNext:(id)sender;


@end
