//
//  ProgrammingUploadViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YaRadio.h"

@interface ProgrammingUploadViewController : UITableViewController

@property (nonatomic, retain) YaRadio* radio;

- (id)initWithStyle:(UITableViewStyle)style  forRadio:(YaRadio*)radio;
- (void)setSegment:(NSInteger)index;

@end
