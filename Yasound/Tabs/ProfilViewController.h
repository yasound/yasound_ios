//
//  ProfilViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBar.h"
#import "TopBar.h"


@interface ProfilViewController : UIViewController<TopBarDelegate, TabBarDelegate>

@property (nonatomic, retain) IBOutlet TabBar* tabBar;

@end