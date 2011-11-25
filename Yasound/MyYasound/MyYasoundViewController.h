//
//  MyYasoundViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 25/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyYasoundViewController : UIViewController
{
  UIView* _viewCurrent;
  IBOutlet UIBarButtonItem* _segmentBarButtonItem;
  IBOutlet UITableView* _tableView;
}

@property (nonatomic, retain) IBOutlet UIView* viewContainer;
@property (nonatomic, retain) IBOutlet UIView* viewMyYasound;
@property (nonatomic, retain) IBOutlet UIView* viewSelection;


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabIcon:(NSString*)tabIcon;
- (IBAction)onmSegmentClicked:(id)sender;

@end
