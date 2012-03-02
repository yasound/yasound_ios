//
//  SongCatalog.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 02/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongCatalog.h"
#import "Song.h"

@implementation SongCatalog

@synthesize alphabeticRepo;
@synthesize artistsRepo;
@synthesize artistsRepoKeys;
@synthesize artistsIndexSections;
@synthesize indexMap;


- (id)init
{
    if (self = [super init])
    {
        _numericSet = [[NSCharacterSet decimalDigitCharacterSet] retain];
        _lowerCaseSet = [[NSCharacterSet lowercaseLetterCharacterSet] retain];
        _upperCaseSet = [[NSCharacterSet uppercaseLetterCharacterSet] retain];
        
        
        self.alphabeticRepo = [[NSMutableDictionary alloc] init];
        self.artistsRepo = [[NSMutableDictionary alloc] init];
        self.artistsIndexSections = [[NSMutableArray alloc] init];
        self.indexMap = [[NSMutableArray alloc] init];
        [self initIndexMap];
        
        for (NSString* indexKey in self.indexMap)
        {
            NSMutableArray* letterRepo = [[NSMutableArray alloc] init];
            [self.alphabeticRepo setObject:letterRepo forKey:indexKey];
        }

    }
    return self;
}


- (void)dealloc
{
    [_numericSet release];
    [_lowerCaseSet release];
    [_upperCaseSet release];
    [super dealloc];
}



- (void)initIndexMap
{
    [self.indexMap addObject:@"-"];
    [self.indexMap addObject:@"A"];
    [self.indexMap addObject:@"B"];
    [self.indexMap addObject:@"C"];
    [self.indexMap addObject:@"D"];
    [self.indexMap addObject:@"E"];
    [self.indexMap addObject:@"F"];
    [self.indexMap addObject:@"G"];
    [self.indexMap addObject:@"H"];
    [self.indexMap addObject:@"I"];
    [self.indexMap addObject:@"J"];
    [self.indexMap addObject:@"K"];
    [self.indexMap addObject:@"L"];
    [self.indexMap addObject:@"M"];
    [self.indexMap addObject:@"N"];
    [self.indexMap addObject:@"O"];
    [self.indexMap addObject:@"P"];
    [self.indexMap addObject:@"Q"];
    [self.indexMap addObject:@"R"];
    [self.indexMap addObject:@"S"];
    [self.indexMap addObject:@"T"];
    [self.indexMap addObject:@"U"];
    [self.indexMap addObject:@"V"];
    [self.indexMap addObject:@"W"];
    [self.indexMap addObject:@"X"];
    [self.indexMap addObject:@"Y"];
    [self.indexMap addObject:@"Z"];
    [self.indexMap addObject:@"#"];
}






- (void)buildWithSource:(NSDictionary*)source
{
    NSArray* songs = [source allValues];
    
    for (Song* song in songs)
    {
        // be aware of empty artist names, and empty album names
        NSString* artistKey = song.artist;
        if ((artistKey == nil) || (artistKey.length == 0))
        {
            artistKey = NSLocalizedString(@"ProgrammingView_unknownArtist", nil);
            NSLog(@"empty artist found!");
        }
        NSString* albumKey = song.album;
        if ((albumKey == nil) || (albumKey.length == 0))
        {
            artistKey = NSLocalizedString(@"ProgrammingView_unknownAlbum", nil);
            NSLog(@"empty album found!");
        }
        
        
        
        // and now,
        // get what u need to sort alphabetically
        NSString* firstRelevantWord = [song getFirstRelevantWord]; // first title's word, excluding the articles
        
        unichar c = [firstRelevantWord characterAtIndex:0];
        
        // we spread the songs, in a dictionnary, and group them depending on their first letter
        // => each table view section will be related to a letter
        
        // first letter is [0 .. 9]
        if ([_numericSet characterIsMember:c]) 
        {
            NSMutableArray* letterRepo = [self.alphabeticRepo objectForKey:@"-"];
            [letterRepo addObject:song];
        }
        // first letter is [a .. z] || [A .. Z]
        else if ([_lowerCaseSet characterIsMember:c] || [_upperCaseSet characterIsMember:c])
        {
            NSString* upperCaseChar = [[NSString stringWithCharacters:&c length:1] uppercaseString];
            NSMutableArray* letterRepo = [self.alphabeticRepo objectForKey:upperCaseChar];
            [letterRepo addObject:song];
        }
        // other cases (foreign languages, ...)
        else
        {
            NSMutableArray* letterRepo = [self.alphabeticRepo objectForKey:@"#"];
            [letterRepo addObject:song];
        }
        
        
        
        // also, take care about the other sorting dictionnary (the one that sort the songs by artists and albums)
        NSMutableDictionary* albumsRepo = [self.artistsRepo objectForKey:artistKey];
        if (albumsRepo == nil)
        {
            albumsRepo = [[NSMutableDictionary alloc] init];
            [self.artistsRepo setObject:albumsRepo forKey:artistKey];
        }
        NSMutableArray* albumRepo = [albumsRepo objectForKey:albumKey];
        if (albumRepo == nil)
        {
            albumRepo = [[NSMutableArray alloc] init];
            [albumsRepo setObject:albumRepo forKey:albumKey];
        }
        [albumRepo addObject:song];
        
        
    }
    
    // now, sort alphabetically each letter repository
    for (NSString* key in [self.alphabeticRepo allKeys])
    {
        // don't sort the foreign languages
        if ([key isEqualToString:@"#"])
            continue;
        
        NSMutableArray* array = [self.alphabeticRepo objectForKey:key];
        NSMutableArray* sortedArray = [array sortedArrayUsingSelector:@selector(nameCompare:)];
        [self.alphabeticRepo setObject:sortedArray forKey:key];
    }
    
    // and finalize the artists repository ergonomy (<=> artists names are keys of the artists repository, and we want to sort them alphabetically)
    self.artistsRepoKeys = [NSArray arrayWithArray:[self.artistsRepo allKeys]];
    self.artistsRepoKeys = [self.artistsRepoKeys  sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    //    NSLog(@"%@", self.artistsRepoKeys);
    
    // also, prepare the relation between the alphabetic scrolling Index, and the artists names
    NSInteger section = 0;
    NSInteger artistIndex = 0;
    [self.artistsIndexSections addObject:[NSNumber numberWithInteger:section]]; // first section of "-" index
    section++;
    for (int i = 1; i < (self.indexMap.count - 1); i++)
    {
        NSString* indexChar = [self.indexMap objectAtIndex:i];
        NSString* firstArtistChar = [[[self.artistsRepoKeys objectAtIndex:artistIndex] substringToIndex:1] uppercaseString];
        
        //        NSLog(@"indexChar %@, firstArtistChar %@", indexChar, firstArtistChar);
        
        // for instance, if indexChar is "A", and firstArtistChar is "B" already (<=> no artist in the "A" index),
        // keep the current index as an index section, and continue
        NSComparisonResult result = [firstArtistChar compare:indexChar];
        if ((result == NSOrderedDescending) || (result == NSOrderedSame))
        {
            [self.artistsIndexSections addObject:[NSNumber numberWithInteger:artistIndex]];
            continue;
        }
        
        // otherwise, go to the artist section, where the first letter corresponds to the indexChar (<=> if indexChar is "B", goes to the first artist in "B")
        while ((artistIndex < (self.artistsRepoKeys.count-1)) && (result == NSOrderedAscending))
        {
            artistIndex++;
            firstArtistChar = [[[self.artistsRepoKeys objectAtIndex:artistIndex] substringToIndex:1] uppercaseString];
            result = [firstArtistChar compare:indexChar];
            
            //            NSLog(@"indexChar %@, firstArtistChar %@", indexChar, firstArtistChar);
        }
        
        [self.artistsIndexSections addObject:[NSNumber numberWithInteger:artistIndex]];
    }
    
    // last section index : it's the "#" section, for the names in foreign characters. Keep the last provided artist index.
    [self.artistsIndexSections addObject:[NSNumber numberWithInteger:artistIndex]];
    
}





@end
