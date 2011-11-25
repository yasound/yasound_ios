//
//  RadioSelectionViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum
{
  RSTSelection = 0,
  RSTTop,
  RSTNew,
  RSTSearch
} RadioSelectionType;


@interface RadioSelectionViewController : UIViewController
{
  IBOutlet UILabel* _topBarLabel;
  IBOutlet UILabel* _topBarTitle;
  IBOutlet UILabel* _categoryTitle;
  
  IBOutlet UITableView* _tableView;  
  
  NSString* _currentStyle;
  RadioSelectionType _type;
}


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil type:(RadioSelectionType)type title:(NSString*)title tabIcon:(NSString*)tabIcon;
- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil type:(RadioSelectionType)type title:(NSString*)title tabItem:(UITabBarSystemItem)tabItem;

- (IBAction)onStyleSelectorClicked:(id)sender;
@end
