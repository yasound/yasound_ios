//
//  RadioSelectionViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QualitySwitchLabel.h"

typedef enum
{
  RSTSelection = 0,
  RSTTop,
  RSTNew,
  RSTSearch
} RadioSelectionType;


@interface RadioSelectionViewController : UIViewController
{
  IBOutlet QualitySwitchLabel* _qualitySwitchLabel;
  IBOutlet UILabel* _topBarTitle;
  IBOutlet UILabel* _categoryTitle;
    IBOutlet UIButton* _nowPlayingButton;
    
  IBOutlet UITableView* _tableView;  
  
  NSString* _currentStyle;
  RadioSelectionType _type;
  
  NSArray* _radios;
}


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil type:(RadioSelectionType)type title:(NSString*)title tabIcon:(NSString*)tabIcon;

- (IBAction)onStyleSelectorClicked:(id)sender;
- (IBAction)onNowPlayingClicked:(id)sender;

@end
