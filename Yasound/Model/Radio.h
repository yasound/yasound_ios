//
//  Radio.h
//  Yasound
//
//  Created by matthieu campion on 12/8/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Model.h"
#import "User.h"


@interface Radio : Model {
    
    NSInteger _assignedTopRank;
}

typedef enum {
    eRadioOriginYasound = 0,
    eRadioOriginRadiowaves
} RadioOrigin;


@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) User* creator;
@property (retain, nonatomic) NSString* description;
@property (retain, nonatomic) NSString* genre;
@property (retain, nonatomic) NSString* theme;
@property (retain, nonatomic) NSString* uuid;
@property (retain, nonatomic) NSNumber* origin; // 0 <=> yasound, 1 <=> radiowaves
//@property (retain, nonatomic) NSArray* playlists;
@property (retain, nonatomic) NSNumber* likes;
@property (retain, nonatomic) NSNumber* favorites;
@property (retain, nonatomic) NSString* picture;
@property (retain, nonatomic) NSString* tags;
@property (retain, nonatomic) NSNumber* ready;
@property (retain, nonatomic) NSNumber* nb_current_users;
@property (retain, nonatomic) NSString* stream_url;
@property (retain, nonatomic) NSString* web_url;
@property (retain, nonatomic) NSNumber* overall_listening_time; // in seconds
@property (retain, nonatomic) NSNumber* new_wall_messages_count;
@property (retain, nonatomic) NSNumber* leaderboard_rank;
@property (retain, nonatomic) NSNumber* leaderboard_favorites;


- (NSArray*)tagsArray;
- (void)setTagsWithArray:(NSArray*)tagArray;

- (NSInteger) assignedTopRank;
- (void)setAssignedTopRank:(NSInteger)rank;

- (NSString*)toString;
 
@end
