//
//  ShareModalViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 16/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareModalViewController : UIViewController<UITextFieldDelegate>
{
    IBOutlet UIBarButtonItem* _buttonCancel;
    IBOutlet UIBarButtonItem* _buttonSend;
    IBOutlet UIImageView* _image;
    IBOutlet UIImageView* _mask;
    
    IBOutlet UILabel* _songTitle;
    IBOutlet UILabel* _songArtist;
    
    id _target;
    SEL _action;
}

@property (nonatomic, retain) NSString* song;
@property (nonatomic, retain) NSString* artist;
@property (nonatomic, retain) NSURL* pictureUrl;
@property (nonatomic, retain) NSURL* fullLink;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forSong:(NSString*)aSong andArtist:(NSString*)anArtist target:(id)target action:(SEL)action;


@end
