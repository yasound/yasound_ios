//
//  FavoritesViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 18/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoritesViewController : UIViewController
{
    IBOutlet UILabel* _toolbarTitle;
    IBOutlet UIBarButtonItem* _nowPlayingButton;
    
    IBOutlet UITableView* _tableView;

    NSArray* _radios;
}

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabIcon:(NSString*)tabIcon;

@end
