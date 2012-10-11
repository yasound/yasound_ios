//
//  GiftCell.h
//  Yasound
//
//  Created by mat on 06/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Gift.h"
#import "WebImageView.h"

@interface GiftCell : UITableViewCell
{
    Gift* _gift;
}

@property (nonatomic, retain) Gift* gift;

@property (nonatomic, retain) WebImageView* image;
@property (nonatomic, retain) UIImageView* mask;
@property (nonatomic, retain) UILabel* label;
@property (nonatomic, retain) UILabel* description;
@property (nonatomic, retain) UILabel* date;
//@property (nonatomic, retain) UILabel* count;
//@property (nonatomic, retain) UILabel* done;
@property (nonatomic, retain) UILabel* disabledLabel;

- (void)setGift:(Gift*)gift;

@end
