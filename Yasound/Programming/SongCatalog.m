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
//@synthesize artistsRepo;
//@synthesize artistsRepoKeys;
//@synthesize artistsIndexSections;
@synthesize indexMap;
@synthesize alphaArtistsRepo;
@synthesize alphaArtistsOrder;
@synthesize alphaArtistsPREORDER;

@synthesize selectedArtist;
@synthesize selectedAlbum;
@synthesize selectedArtistRepo;
@synthesize selectedAlbumRepo;


- (id)init
{
    if (self = [super init])
    {
        _numericSet = [[NSCharacterSet decimalDigitCharacterSet] retain];
        _lowerCaseSet = [[NSCharacterSet lowercaseLetterCharacterSet] retain];
        _upperCaseSet = [[NSCharacterSet uppercaseLetterCharacterSet] retain];
        
        
        self.alphabeticRepo = [[NSMutableDictionary alloc] init];
//        self.artistsRepo = [[NSMutableDictionary alloc] init];
//        self.artistsIndexSections = [[NSMutableArray alloc] init];
        
        self.alphaArtistsRepo = [[NSMutableDictionary alloc] init];
        self.alphaArtistsPREORDER = [[NSMutableDictionary alloc] init];
        self.alphaArtistsOrder = [[NSMutableDictionary alloc] init];
        
        
        self.indexMap = [[NSMutableArray alloc] init];
        [self initIndexMap];
        
        for (NSString* indexKey in self.indexMap)
        {
            NSMutableArray* letterRepo = [[NSMutableArray alloc] init];
            [self.alphabeticRepo setObject:letterRepo forKey:indexKey];

            NSMutableDictionary* letterArtistRepo = [[NSMutableDictionary alloc] init];
            [self.alphaArtistsRepo setObject:letterArtistRepo forKey:indexKey];

            NSMutableDictionary* letterArtistPREORDER = [[NSMutableDictionary alloc] init];
            [self.alphaArtistsPREORDER setObject:letterArtistPREORDER forKey:indexKey];
            
            NSMutableArray* letterArtistOrder = [[NSMutableArray alloc] init];
            [self.alphaArtistsOrder setObject:letterArtistOrder forKey:indexKey];
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

        
        
        //LBDEBUG
        NSLog(@"%@ | %@ | %@", artistKey, albumKey, song.name);
        
        // now the Artist / Album / Song catalog
        c = [song.artist characterAtIndex:0];
        NSMutableDictionary* artistRepo = nil;
        NSMutableDictionary* artistPREORDER = nil;
        if ([_numericSet characterIsMember:c])
        {
            artistRepo = [self.alphaArtistsRepo objectForKey:@"-"];
            artistPREORDER = [self.alphaArtistsPREORDER objectForKey:@"-"];
        }
        else if ([_lowerCaseSet characterIsMember:c] || [_upperCaseSet characterIsMember:c])
        {
            NSString* upperC = [[NSString stringWithCharacters:&c length:1] uppercaseString];
            //LBDEBUG
            NSLog(@"upperC %@", upperC);
            artistRepo = [self.alphaArtistsRepo objectForKey:upperC];
            artistPREORDER = [self.alphaArtistsPREORDER objectForKey:upperC];
        }
        else
        {
            artistRepo = [self.alphaArtistsRepo objectForKey:@"#"];
            artistPREORDER = [self.alphaArtistsPREORDER objectForKey:@"#"];
        }
        
        // store artist name, to be alphabetically sorted later
        // => we use a dictionary here to optimize the insert operation (the inserted object must be unique)
        // => when it'll be completed, the dictionnary will be turned into a array and we will sort it alphabetically
        [artistPREORDER setObject:artistKey forKey:artistKey];
            
        // store the song in the right repository
        NSMutableArray* albumRepo = [artistRepo objectForKey:albumKey];
        if (albumRepo == nil)
        {
            albumRepo = [[NSMutableArray alloc] init];
            [artistRepo setObject:albumRepo forKey:albumKey];
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
    

    // and sort the artist repository order
    for (NSString* indexKey in self.indexMap)
    {
        NSDictionary* artistPREORDER = [self.alphaArtistsPREORDER objectForKey:indexKey];
        NSArray* array = [artistPREORDER allValues];
        
        // alphabetic sort
        array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        [self.alphaArtistsOrder setObject:array forKey:indexKey];
    }
    for (NSString* key in [self.alphaArtistsOrder allKeys])
    {
        // don't sort the foreign languages
        if ([key isEqualToString:@"#"])
            continue;
        
        NSMutableArray* array = [self.alphaArtistsOrder objectForKey:key];
        NSMutableArray* sortedArray = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        [self.alphaArtistsOrder setObject:sortedArray forKey:key];
    }
    
}






- (BOOL)selectArtistInSection:(NSInteger)section atRow:(NSInteger)row
{
    // first, reset album selection
    self.selectedAlbum = nil;
    self.selectedAlbumRepo = nil;
    
    if (section >= self.indexMap.count)
        return NO;
    
    // now, select artist
    NSString* charIndex = [self.indexMap objectAtIndex:section];
    NSArray* artistsForSection = [self.alphaArtistsOrder objectForKey:charIndex];
    
    if (row >= artistsForSection.count)
        return NO;

    NSString* artist = [artistsForSection objectAtIndex:row];
    
    self.selectedArtist = artist;
    
    NSDictionary* artistsRepo = [self.alphaArtistsRepo objectForKey:charIndex];
    self.selectedArtistRepo = [artistsRepo objectForKey:artist];
    
    return YES;
}


- (BOOL)selectAlbumAtRow:(NSInteger)row
{
    if (self.selectedArtistRepo == nil)
        return NO;
        
    NSArray* albums = [self.selectedArtistRepo allValues];
    
    if (row >= albums.count)
        return NO;
    
    self.selectedAlbum = [albums objectAtIndex:row];
    
    self.selectedAlbumRepo = [self.selectedArtistRepo objectForKey:self.selectedAlbum];
    
    return YES;
}


- (Song*)getSongAtRow:(NSInteger)row;
{
    if (self.selectedAlbumRepo == nil)
        return nil;
    
    if (row >= self.selectedAlbumRepo.count)
        return nil;
    
    return [self.selectedAlbumRepo objectAtIndex:row];
}




@end
