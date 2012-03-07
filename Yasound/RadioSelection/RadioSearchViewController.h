//
//  RadioSearchViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 28/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YasoundDataProvider.h"
#import "TestflightViewController.h"


@interface RadioSearchViewController : TestflightViewController
{
    IBOutlet UITableView* _tableView;
    IBOutlet UIBarButtonItem* _nowPlayingButton;
    IBOutlet UISearchDisplayController* _searchController;

  NSArray* _radios;
  NSArray* _radiosByCreator;
  NSArray* _radiosBySong;
  
  BOOL _viewVisible;
}


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabItem:(UITabBarSystemItem)tabItem;

- (IBAction)nowPlayingClicked:(id)sender;

@end
