//
//  ShareTwitterModalViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 16/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
#import "WebImageView.h"
#import "Radio.h"

@interface ShareTwitterModalViewController : UIViewController<UITextFieldDelegate>
{
    IBOutlet UIBarButtonItem* _itemTitle;
    IBOutlet UIBarButtonItem* _buttonCancel;
    IBOutlet UIBarButtonItem* _buttonSend;
    IBOutlet WebImageView* _image;
    IBOutlet UIImageView* _mask;
    
    IBOutlet UILabel* _songTitle;
    IBOutlet UILabel* _songArtist;
    
    IBOutlet UITextView* _textView;
    
    IBOutlet UILabel* _statusLabel1;
    IBOutlet UILabel* _statusLabel2;
    
    id _target;
    SEL _action;
}

@property (nonatomic, retain) Song* song;
@property (nonatomic, retain) Radio* radio;
@property (nonatomic, retain) NSURL* pictureUrl;
@property (nonatomic, retain) NSURL* fullLink;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forSong:(Song*)aSong onRadio:(Radio*)aRadio target:(id)target action:(SEL)action;


@end
