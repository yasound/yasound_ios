//
//  Radio.m
//  Yasound
//
//  Created by matthieu campion on 12/8/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "YaRadio.h"

@implementation YaRadio

@synthesize name;
@synthesize creator;
@synthesize description;
@synthesize genre;
@synthesize theme;
@synthesize uuid;
//@synthesize playlists;
@synthesize likes;
@synthesize favorites;
@synthesize picture;
@synthesize tags;
@synthesize ready;
@synthesize nb_current_users;
@synthesize stream_url;
@synthesize web_url;
@synthesize overall_listening_time;
@synthesize new_wall_messages_count;

- (NSArray*)tagsArray
{
    NSString* tagsStr = self.tags;
    if (!tagsStr || [tagsStr compare:@""] == NSOrderedSame)
        return nil;
    NSArray* tagsArray = [tagsStr componentsSeparatedByString:@","];
    return tagsArray;
}

- (void)setTagsWithArray:(NSArray*)tagArray;
{
    NSMutableString* str = [NSMutableString string];
    BOOL first = YES;
    for (NSString* t in tagArray) 
    {
        if (first)
        {
            [str appendString:t];
            first = NO;
        }
        else
        {
            [str appendFormat:@",%@", t];
        }
    }
    self.tags = str;
}


- (NSInteger) assignedTopRank {
    
    return _assignedTopRank;
}


- (void)setAssignedTopRank:(NSInteger)rank {
    
    _assignedTopRank = rank;
}


-(NSString*)toString
{
    NSString* desc = [NSString stringWithFormat:@"id: '%@', name: '%@', creator: '%@', description: '%@', genre: '%@', theme: '%@', uuid: '%@'", self.id, self.name, self.creator.username, self.description, self.genre, self.theme, self.uuid];
    return desc;
}

@end
