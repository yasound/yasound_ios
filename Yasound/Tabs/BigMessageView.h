//
//  BigMessageView.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BigMessageView : UIView

@property (nonatomic, retain) id target;
@property (nonatomic) SEL action;

- (id)initWithFrame:(CGRect)frame message:(NSString*)message actionTitle:(NSString*)actionTitle target:(id)target action:(SEL)action;

@end
