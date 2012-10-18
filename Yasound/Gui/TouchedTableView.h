//
//  TouchedTableView.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 25/05/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TouchedTableView : UITableView

@property (nonatomic) SEL actionTouched;



- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;




@end
