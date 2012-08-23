//
//  PurchaseViewController.h
//  Yasound
//
//  Created by neywen on 23/08/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "YaViewController.h"
#import <StoreKit/StoreKit.h>
#import <StoreKit/SKPaymentTransaction.h>


@interface PurchaseViewController : YaViewController<SKProductsRequestDelegate, SKPaymentTransactionObserver>

@end
