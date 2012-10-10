//
//  PurchaseTableViewCell.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "PurchaseTableViewCell.h"

@implementation PurchaseTableViewCell


@synthesize image;
@synthesize title;
@synthesize subtitle;
@synthesize price;



- (void)updateForProduct:(SKProduct*)product withSubscription:(Subscription*)sub
{
    
    self.subscription = sub;
    
    if ([self.subscription isHighlighted])
        self.image.image = [UIImage imageNamed:@"productIconBest.png"];
    else
        self.image.image = [UIImage imageNamed:@"productIconDefault.png"];

    self.title.text = product.localizedTitle;
    self.subtitle.text = product.localizedDescription;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
    
    self.price.text = formattedString;
    
    CGFloat alpha = 1;
    if (![self.subscription isEnabled])
        alpha = 0.5;
    self.image.alpha = alpha;
    self.title.alpha = alpha;
    self.subtitle.alpha = alpha;
    self.price.alpha = alpha;
    
}







- (void)dealloc
{
    [super dealloc];
}




- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
}





@end
