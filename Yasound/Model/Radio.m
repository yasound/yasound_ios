//
//  Radio.m
//  Yasound
//
//  Created by matthieu campion on 12/8/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Radio.h"

@implementation Radio

@synthesize name;
@synthesize creator;
@synthesize description;
@synthesize genre;
@synthesize theme;
@synthesize uuid;
@synthesize playlists;
@synthesize likes;
@synthesize favorites;
@synthesize picture;
@synthesize tags;
@synthesize ready;
@synthesize nb_current_users;
@synthesize stream_url;
@synthesize web_url;

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


-(NSString*)toString
{
    NSString* desc = [NSString stringWithFormat:@"name: '%@', creator: '%@', description: '%@', genre: '%@', theme: '%@', uuid: '%@' playlist count: '%d", self.name, self.creator.username, self.description, self.genre, self.theme, self.uuid, [self.playlists count]];
    return desc;
}

@end
