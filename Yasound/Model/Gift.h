//
//  Gift.h
//  Yasound
//
//  Created by mat on 05/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Model.h"

@interface Gift : Model

@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) NSString* description;
@property (retain, nonatomic) NSString* action_url_ios;
@property (retain, nonatomic) NSString* completed_url;
@property (retain, nonatomic) NSString* picture_url;
@property (retain, nonatomic) NSNumber* enabled;
@property (retain, nonatomic) NSDate* last_achievement_date;
@property (retain, nonatomic) NSNumber* count;
@property (retain, nonatomic) NSNumber* max;

- (BOOL)canBeWon;
- (BOOL)hasBeenWon;
- (BOOL)hasBeenFullyWon;

- (NSString*)countProgress;
- (NSString*)formattedDate;

- (void)doAction;

@end
