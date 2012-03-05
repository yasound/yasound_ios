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
#import "RadioListeningStat.h"

@interface StatsViewController : TestflightViewController
{
    IBOutlet UIBarButtonItem* _backBtn;
    IBOutlet UILabel* _titleLabel;
    
    IBOutlet UITableViewCell* _cellMonthSelector;
  IBOutlet UITableViewCell* _cellLeaderBoardSelector;

    IBOutlet UIButton* _btnPreviousWeek;
    IBOutlet UIButton* _btnNextWeek;
    IBOutlet UIButton* _btnPreviousMonth;
    IBOutlet UIButton* _btnNextMonth;

    IBOutlet UILabel* _cellMonthSelectorLabel;
  IBOutlet UILabel* _cellLeaderBoardSelectorLabel;
    
    IBOutlet UITableView* _tableView;  
    
    UIView* _weekGraphBoundingBox;

    UIView* _monthGraphBoundingBox;
  
  ChartView* _monthGraphView;
  
  UILabel* _listenersLabel;
  
  NSArray* _leaderboard;
}

- (IBAction)onBack:(id)sender;

- (IBAction)onPreviousWeek:(id)sender;
- (IBAction)onNextWeek:(id)sender;
- (IBAction)onPreviousMonth:(id)sender;
- (IBAction)onNextMonth:(id)sender;

@end
