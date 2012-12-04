//
//  ProfilCellRadio.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebImageView.h"
#import "YaRadio.h"



@interface ProfilCellRadio : UIView

@property (nonatomic, assign) YaRadio* radio;
@property (nonatomic, assign) WebImageView* image;
@property (nonatomic, assign) UILabel* text;

- (id)initWithRadio:(YaRadio*)radio;



@end
