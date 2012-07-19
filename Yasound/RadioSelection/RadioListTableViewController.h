//
//  RadioListTableViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 19/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Radio.h"


@protocol RadioListDelegate <NSObject>
- (void)radioListDidSelect:(Radio*)radio;
@end


@interface RadioListTableViewController : UITableViewController

@property (nonatomic, retain) id<RadioListDelegate> listDelegate;
@property (nonatomic, retain) NSArray* radios;

- (id)initWithStyle:(UITableViewStyle)style radios:(NSArray*)radios;



@end
