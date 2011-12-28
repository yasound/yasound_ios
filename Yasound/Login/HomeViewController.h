//
//  HomeViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyTracker.h"


@interface HomeViewController : TrackedUIViewController
{
    IBOutlet UIView* _container;
    IBOutlet UIView* _defaultView;    
    IBOutlet UIView* _loginView;
    IBOutlet UITableView* _tableView;
    
    //...............................................
    IBOutlet UILabel* _facebookLoginLabel;
    IBOutlet UILabel* _twitterLoginLabel;

}

@end






