//
//  BigMessageView.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InteractiveView.h"


@interface BigMessageView : UIView

@property (nonatomic, retain) id target;
@property (nonatomic) SEL action;
@property (nonatomic, retain) UILabel* message;
@property (nonatomic, retain) UIButton* button;
@property (nonatomic, retain) UILabel* buttonLabel;


- (id)initWithFrame:(CGRect)frame messageId:(NSString*)messageId target:(id)target action:(SEL)action;

@end
