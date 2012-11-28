//
//  ProgrammingUploadViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YasoundRadio.h"

@interface ProgrammingUploadViewController : UITableViewController

@property (nonatomic, retain) YasoundRadio* radio;

- (id)initWithStyle:(UITableViewStyle)style  forRadio:(YasoundRadio*)radio;
- (void)setSegment:(NSInteger)index;

@end
