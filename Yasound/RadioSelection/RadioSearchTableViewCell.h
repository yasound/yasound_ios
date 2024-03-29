//
//  RadioSearchTableViewCell.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebImageView.h"
#import "YasoundDataProvider.h"


@interface RadioSearchTableViewCell : UITableViewCell


@property (nonatomic, retain) NSMutableArray* radioObjects; //array of array [Radio*, View*] 
@property (nonatomic, retain) id target;
@property (nonatomic) SEL action;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier radios:(NSArray*)radios target:(id)target action:(SEL)action;
- (void)updateWithRadios:(NSArray*)radios target:(id)target action:(SEL)action;

@end
