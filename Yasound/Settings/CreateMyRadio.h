//
//  CreateMyRadio.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 17/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Radio.h"
#import "EasyTracker.h"


@interface CreateMyRadio : TrackedUIViewController
{
    BOOL _wizard;
    
//    IBOutlet UIToolbar* _toolbar;
    IBOutlet UILabel* _toolbarTitle;
    IBOutlet UILabel* _text;
    IBOutlet UIButton* _goButton;
    IBOutlet UIButton* _skipButton;
}

@property (nonatomic, retain) Radio* radio;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil wizard:(BOOL)wizard radio:(Radio*)aRadio;


@end
