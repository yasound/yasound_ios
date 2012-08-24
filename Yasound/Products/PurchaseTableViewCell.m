//
//  PurchaseTableViewCell.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "PurchaseTableViewCell.h"
//#import "YasoundDataProvider.h"
//#import "Theme.h"
//#import <QuartzCore/QuartzCore.h>
//#import "ActivityAlertView.h"
//#import "RootViewController.h"



#define PRODUCTID_YAHD1M @"yaHD1m"
#define PRODUCTID_YAHD1Y @"yaHD1y"
#define PRODUCTID_YAHD1YS @"yaHD1ysp"

@implementation PurchaseTableViewCell


@synthesize image;
@synthesize title;
@synthesize subtitle;
@synthesize price;



//@property(nonatomic, readonly) NSString *localizedDescription __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);
//
//@property(nonatomic, readonly) NSString *localizedTitle __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);
//
//@property(nonatomic, readonly) NSDecimalNumber *price __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);
//
//@property(nonatomic, readonly) NSLocale *priceLocale __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);
//
//@property(nonatomic, readonly) NSString *productIdentifier __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);


- (void)updateForProduct:(SKProduct*)product
{
    if ([product.productIdentifier isEqualToString:PRODUCTID_YAHD1Y])
        self.image.image = [UIImage imageNamed:@"productIconBest.png"];
    else
        self.image.image = [UIImage imageNamed:@"productIconDefault.png"];

    self.title.text = product.localizedTitle;
    self.subtitle.text = product.localizedDescription;
    self.price.text = product.price;
}






- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if(!newSuperview)
    {
        if (self.image)
            [self.image releaseCache];
    }
}





- (void)dealloc
{
    [super dealloc];
}

















- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
}








@end
