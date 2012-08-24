//
//  Subscription.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Model.h"

@interface Subscription : Model

@property (retain, nonatomic) NSString* sku;
@property (retain, nonatomic) NSString* description;
@property (retain, nonatomic) NSNumber* enabled;
@property (retain, nonatomic) NSNumber* duration;
@property (retain, nonatomic) NSNumber* subscription_id;
@property (retain, nonatomic) NSString* name;

- (BOOL)isEnabled;

@end

//{
//    "meta":{
//        "previous":null,
//        "total_count":3,
//        "offset":0,
//        "limit":25,
//        "next":null
//    },
//    "objects":[
//               {
//                   "sku":"HD",
//                   "description":"HD",
//                   "enabled":true,
//                   "duration":1,
//                   "id":1,
//                   "name":"HD 1 month"
//               },
//               {
//                   "sku":"",
//                   "description":"",
//                   "enabled":true,
//                   "duration":12,
//                   "id":2,
//                   "name":"HD 1 year"
//               },
//               {
//                   "sku":"",
//                   "description":"",
//                   "enabled":true,
//                   "duration":12,
//                   "id":3,
//                   "name":"HD 1 year/w selection"
//               }
//               ]
//}

