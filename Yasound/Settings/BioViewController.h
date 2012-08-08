//
//  BioViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 16/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
#import "WebImageView.h"
#import "Radio.h"

#define BIO_LENGTH_MAX 190.f

@protocol BioDelegate <NSObject>
- (void)bioDidReturn:(NSString*)bio;
@end

@interface BioViewController : UIViewController<UITextFieldDelegate>
{
    IBOutlet UIBarButtonItem* _itemTitle;
//    IBOutlet UIBarButtonItem* _buttonCancel;
//    IBOutlet UIBarButtonItem* _buttonSave;
    IBOutlet WebImageView* _image;
    IBOutlet UIImageView* _mask;
    
    IBOutlet UILabel* _label1;
//    IBOutlet UILabel* _label2;
    
    IBOutlet UITextView* _textView;
}

@property (nonatomic, retain) User* user;
@property (nonatomic, retain) id<BioDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forUser:(User*)user target:(id)target;


@end
