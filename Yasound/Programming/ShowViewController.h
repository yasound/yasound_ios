//
//  ShowViewController.h
//  Yasound
//
//  Created by neywen on 11/08/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UIPickerView* pickerview;
@property (nonatomic, retain) NSMutableArray* days;
@property (nonatomic, retain) NSMutableArray* hours;
@property (nonatomic, retain) NSMutableArray* minutes;

@end
