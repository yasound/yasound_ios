//
//  FavoritesViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 18/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestflightViewController.h"

@interface FavoritesViewController : TestflightViewController
{
    IBOutlet UILabel* _toolbarTitle;
    IBOutlet UIBarButtonItem* _nowPlayingButton;
    
    IBOutlet UITableView* _tableView;

    NSArray* _radios;
}

@property (nonatomic, retain) NSURL* url;

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withUrl:(NSURL*)aUrl;

@end
