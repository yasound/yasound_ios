//
//  MyRadiosTableViewCell.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Radio.h"
#import "WebImageView.h"

@protocol MyRadiosTableViewCellDelegate <NSObject>
- (void)myRadioRequestedStats:(Radio*)radio;
- (void)myRadioRequestedSettings:(Radio*)radio;
@end

@interface MyRadiosTableViewCell : UITableViewCell

@property (nonatomic, retain) id<MyRadiosTableViewCellDelegate> delegate;
@property (nonatomic, retain) Radio* radio;
@property (nonatomic, retain) WebImageView* image;
@property (nonatomic, retain) UILabel* title;
@property (nonatomic, retain) UILabel* subscribers;
@property (nonatomic, retain) UILabel* listeners;
@property (nonatomic, retain) UILabel* metric1;
@property (nonatomic, retain) UILabel* metric2;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier radio:(Radio*)radio target:(id)target;
- (void)updateWithRadio:(Radio*)radio;

@end
