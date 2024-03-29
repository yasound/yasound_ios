//
//  MessageBroadcastModalViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 16/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
#import "WebImageView.h"
#import "YaRadio.h"
#import "TopBarSaveOrCancel.h"

@interface MessageBroadcastModalViewController : YaViewController<UITextFieldDelegate, TopBarSaveOrCancelDelegate>
{
    IBOutlet WebImageView* _image;
    IBOutlet UIImageView* _mask;
    IBOutlet UITextView* _textView;
    
    IBOutlet UILabel* _label1;
    IBOutlet UILabel* _label2;
    
    
    id _target;
    SEL _action;
}

@property (nonatomic, retain) YaRadio* radio;
@property (nonatomic, assign) NSArray* subscribers;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forRadio:(YaRadio*)aRadio subscribers:(NSArray*)subscribers target:(id)target action:(SEL)action;


@end
