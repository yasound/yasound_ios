//
//  Subscription.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Model.h"

@interface Subscription : Model

@property (retain, nonatomic) NSString* sku;
@property (retain, nonatomic) NSNumber* duration;
@property (retain, nonatomic) NSNumber* current;
@property (retain, nonatomic) NSNumber* enabled;
@property (retain, nonatomic) NSNumber* highlighted;



- (BOOL)isEnabled;
- (BOOL)isCurrent;
- (BOOL)isHighlighted;
- (NSString*)toString;

@end

