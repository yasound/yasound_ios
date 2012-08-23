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

@property(nonatomic, retain) NSMutableArray* productIdentifierList;
@property(nonatomic, retain) NSMutableArray* productDetailsList;
@property(nonatomic, retain) IBOutlet UITableView* tableview;

@end
