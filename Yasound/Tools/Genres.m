//
//  Genres.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 2012
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "genres.h"

@implementation Genres


+ (NSArray*)genres {

    // get the list of genres, depending the prefered language
    
    NSDictionary* resources = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Resources"];
    NSDictionary* dico = [resources objectForKey:@"genres"];
    NSArray* array = nil;
    
    NSString* preferredLang = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([preferredLang isEqualToString:@"fr"]) {
        array = [dico objectForKey:@"fr"];
    }
    else  {
        array = [dico objectForKey:@"en"];
    }
    
    return array;
}



@end
