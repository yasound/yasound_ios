//
//  ProfilCellRadio.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 2012/08/01
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Radio.h"
#import "WebImageView.h"


@interface ProfilCellRadio : UITableViewCell

@property (nonatomic, retain) IBOutlet WebImageView* image;
@property (nonatomic, retain) IBOutlet UILabel* title;


- (void)updateWithRadio:(Radio*)radio;


@end
