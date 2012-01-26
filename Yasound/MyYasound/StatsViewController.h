//
//  StatsViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 21/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestflightViewController.h"
#import "ChartView.h"

@interface StatsViewController : TestflightViewController
{
    IBOutlet UIBarButtonItem* _backBtn;
    IBOutlet UILabel* _titleLabel;
    
    IBOutlet UITableViewCell* _cellWeekSelector;
    IBOutlet UITableViewCell* _cellMonthSelector;

    IBOutlet UIButton* _btnPreviousWeek;
    IBOutlet UIButton* _btnNextWeek;
    IBOutlet UIButton* _btnPreviousMonth;
    IBOutlet UIButton* _btnNextMonth;

    IBOutlet UILabel* _cellWeekSelectorLabel;
    IBOutlet UILabel* _cellMonthSelectorLabel;
    
    IBOutlet UITableView* _tableView;  
    
    UIView* _weekGraphBoundingBox;

    UIView* _monthGraphBoundingBox;
}

@property (nonatomic, retain) ChartView* weekGraphView;
@property (nonatomic, retain) ChartView* monthGraphView;


- (void)reloadData;

- (IBAction)onBack:(id)sender;

- (IBAction)onPreviousWeek:(id)sender;
- (IBAction)onNextWeek:(id)sender;
- (IBAction)onPreviousMonth:(id)sender;
- (IBAction)onNextMonth:(id)sender;

@end
