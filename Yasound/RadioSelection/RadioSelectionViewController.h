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
  
  NSString* _currentStyle;
}


//@property (nonatomic, retain) IBOutlet UILabel* _topBarLabel;
//@property (nonatomic, retain) IBOutlet UILabel* _topBarTitle;
//@property (nonatomic, retain) IBOutlet UILabel* _categoryTitle;
//
//@property (nonatomic, retain) IBOutlet UITableView* _tableView;  



- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabIcon:(NSString*)tabIcon;
- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabItem:(UITabBarSystemItem)tabItem;

- (IBAction)onStyleSelectorClicked:(id)sender;
@end
