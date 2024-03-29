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
#import "PurchaseTableViewCell.h"
#import "WebImageView.h"


@interface PurchaseViewController : YaViewController<SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, retain) UINib* cellLoader;

@property(nonatomic, retain) NSArray* services;
@property(nonatomic, retain) NSArray* subscriptions;
@property(nonatomic, retain) NSMutableArray* productIdentifierList;
@property(nonatomic, retain) NSMutableArray* productDetailsList;

@property(nonatomic, retain) IBOutlet UITableView* tableview;

@property (nonatomic, retain) IBOutlet UITableViewCell* cellProfil;
@property (nonatomic, retain) IBOutlet WebImageView* cellProfilImage;
@property (nonatomic, retain) IBOutlet UILabel* cellProfilLabel;



@end
