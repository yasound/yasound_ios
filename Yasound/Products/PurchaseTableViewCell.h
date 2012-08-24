//
//  PurchaseTableViewCell.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>



@interface PurchaseTableViewCell : UITableViewCell


@property (nonatomic, retain) IBOutlet UIImageView* image;
@property (nonatomic, retain) IBOutlet UILabel* title;
@property (nonatomic, retain) IBOutlet UILabel* subtitle;
@property (nonatomic, retain) IBOutlet UILabel* price;


- (void)updateForProduct:(SKProduct*)product;

@end
