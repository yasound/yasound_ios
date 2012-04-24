//
//  ShareModalViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 16/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
#import "WebImageView.h"

@interface ShareModalViewController : UIViewController<UITextFieldDelegate>
{
    IBOutlet UIBarButtonItem* _itemTitle;
    IBOutlet UIBarButtonItem* _buttonCancel;
    IBOutlet UIBarButtonItem* _buttonSend;
    IBOutlet WebImageView* _image;
    IBOutlet UIImageView* _mask;
    
    IBOutlet UILabel* _songTitle;
    IBOutlet UILabel* _songArtist;
    
    IBOutlet UITextView* _textView;
    
    id _target;
    SEL _action;
}

@property (nonatomic, retain) Song* song;
@property (nonatomic, retain) NSURL* pictureUrl;
@property (nonatomic, retain) NSURL* fullLink;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forSong:(Song*)aSong target:(id)target action:(SEL)action;


@end
