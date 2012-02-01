//
//  RadioListeningStat.h
//  Yasound
//
//  Created by matthieu campion on 1/31/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Model.h"

@interface RadioListeningStat : Model

@property (retain ,nonatomic) NSString* radio; // radio uri
@property (retain ,nonatomic) NSDate* date;
@property (retain ,nonatomic) NSNumber* overall_listening_time;
@property (retain ,nonatomic) NSNumber* audience;
@property (retain ,nonatomic) NSNumber* favorites;
@property (retain ,nonatomic) NSNumber* likes;
@property (retain ,nonatomic) NSNumber* dislikes;


@end
