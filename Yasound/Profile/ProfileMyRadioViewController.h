//
//  ProfileMyRadioViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 29/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Radio.h"
#import "WebImageView.h"



@interface ProfileMyRadioViewController : UIViewController
{
    IBOutlet UIBarButtonItem* _backBtn;
    IBOutlet UIBarButtonItem* _titleLabel;
    IBOutlet UITableView* _tableView;
    IBOutlet UIBarButtonItem* _nowPlayingButton;
    
    IBOutlet UITableViewCell* _cellSendMessage;
    IBOutlet UIImageView* _imageViewSendMessage;
    IBOutlet UILabel* _labelSendMessage;
    
    WebImageView* _imageView;
    NSArray* _subscribers;
    UILabel* _name;
}

@property (nonatomic, retain) Radio* radio;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil radio:(Radio*)myRadio;

- (IBAction)onBack:(id)sender;

@end
