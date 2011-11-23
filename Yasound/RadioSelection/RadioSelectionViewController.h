//
//  RadioSelectionViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>





@interface RadioSelectionViewController : UIViewController
{
  IBOutlet UILabel* _topBarLabel;
  IBOutlet UILabel* _topBarTitle;
  IBOutlet UILabel* _categoryTitle;
  
  IBOutlet UITableView* _tableView;
}


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabIcon:(NSString*)tabIcon;
- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabItem:(UITabBarSystemItem)tabItem;

@end
