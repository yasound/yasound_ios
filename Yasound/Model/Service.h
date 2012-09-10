//
//  Service.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Model.h"

@interface Service : Model

@property (retain, nonatomic) NSNumber* active;
@property (retain, nonatomic) NSDate* expiration_date;
@property (retain, nonatomic) NSString* service;
@property (retain, nonatomic) NSNumber* service_type;



- (BOOL)isActive;
- (BOOL)isHd;

@end

