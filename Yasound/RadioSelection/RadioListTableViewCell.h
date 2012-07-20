//
//  RadioListTableViewCell.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebImageView.h"
#import "YasoundDataProvider.h"


@interface RadioListTableViewCell : UITableViewCell


@property (nonatomic, retain) NSMutableArray* radioObjects; //array of array [Radio*, UILabel*, UILabel*, UILabel*, WebImageView*, WebImageView*] 


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier radios:(NSArray*)radios;
- (void)updateWithRadios:(NSArray*)radios;

@end
