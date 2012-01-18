//
//  FriendsViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 18/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsViewController : UIViewController
{
    IBOutlet UIToolbar* _toolbar;
    IBOutlet UILabel* _toolbarTitle;
    IBOutlet UIBarButtonItem* _nowPlayingButton;
    
}


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabIcon:(NSString*)tabIcon;

@end

