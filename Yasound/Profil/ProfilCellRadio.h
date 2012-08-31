//
//  ProfilCellRadio.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebImageView.h"
#import "Radio.h"



@interface ProfilCellRadio : UIView

@property (nonatomic, assign) id target;
@property (nonatomic) SEL action;
@property (nonatomic, assign) Radio* radio;


- (id)initWithRadio:(Radio*)radio target:(id)target  action:(SEL)action;



@end
