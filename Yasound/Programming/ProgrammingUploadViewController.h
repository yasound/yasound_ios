//
//  ProgrammingUploadViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Radio.h"

@interface ProgrammingUploadViewController : UITableViewController

@property (nonatomic, retain) Radio* radio;

- (id)initWithStyle:(UITableViewStyle)style  forRadio:(Radio*)radio;
- (void)setSegment:(NSInteger)index;

@end
