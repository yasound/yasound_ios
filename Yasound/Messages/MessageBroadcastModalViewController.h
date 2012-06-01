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
#import "Radio.h"

@interface MessageBroadcastModalViewController : UIViewController<UITextFieldDelegate>
{
    IBOutlet UIBarButtonItem* _itemTitle;
    IBOutlet UIBarButtonItem* _buttonCancel;
    IBOutlet UIBarButtonItem* _buttonSend;
    IBOutlet WebImageView* _image;
    IBOutlet UIImageView* _mask;
    
    IBOutlet UILabel* _label1;
    IBOutlet UILabel* _label2;
    
    IBOutlet UITextView* _textView;
    
    id _target;
    SEL _action;
}

@property (nonatomic, retain) Radio* radio;
@property (nonatomic, retain) NSURL* pictureUrl;
@property (nonatomic, retain) NSURL* fullLink;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forRadio:(Radio*)aRadio target:(id)target action:(SEL)action;


@end
