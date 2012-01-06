//
//  RadioSearchViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 28/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YasoundDataProvider.h"

@interface RadioSearchViewController : UIViewController
{
  IBOutlet UITableView* _tableView;
    NSArray* _radios;
}


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabItem:(UITabBarSystemItem)tabItem;

@end
