//
//  SongLocal.m
//  Yasound
//
//  Created by loïc berthelot.
//  Copyright (c) 2012 Yasound. All rights reserved.
//


#import "SongLocal.h"


#define PM_FIELD_UNKNOWN @""


@implementation SongLocal

@synthesize catalogKey;
@synthesize mediaItem;

@synthesize artistKey;
@synthesize albumKey;

@synthesize genre;
@synthesize playbackDuration; 
@synthesize albumTrackNumber;
@synthesize albumTrackCount;
@synthesize artwork;
@synthesize rating;




+ (NSString*)catalogKeyOfSong:(NSString*)name artistKey:(NSString*)artistKey albumKey:(NSString*)albumKey
{
    return [NSString stringWithFormat:@"%@|%@|%@", name, artistKey, albumKey];
}



- (id)initWithMediaItem:(MPMediaItem*)item
{
    if (self = [super init])
    {
        self.mediaItem = item;
        
        self.name = [item valueForProperty:MPMediaItemPropertyTitle];
        
        self.artistKey = [item valueForProperty:MPMediaItemPropertyArtist];
        self.albumKey = [item valueForProperty:MPMediaItemPropertyAlbumTitle];

        // don't read the other information now.
        // do it the properties' getters, since we don't need those information in the catalog.
        
        if ((self.name == nil) || (self.name.length == 0))
            self.name = [NSString stringWithString:PM_FIELD_UNKNOWN];
        
        if ((self.artistKey == nil) || (self.artistKey.length == 0))
        {
            self.artistKey = NSLocalizedString(@"ProgrammingView_unknownArtist", nil);
            self.artist = [NSString stringWithString:PM_FIELD_UNKNOWN];
        }
        else
            self.artist = [NSString stringWithString:self.artistKey];
        
        
        if ((self.albumKey == nil) || (self.albumKey.length == 0))
        {
            self.albumKey =  NSLocalizedString(@"ProgrammingView_unknownAlbum", nil);
            self.album = [NSString stringWithString:PM_FIELD_UNKNOWN];
        }
        else
            self.album = [NSString stringWithString:self.albumKey];
        
        
        
        
        self.catalogKey = [NSString stringWithString:[SongLocal catalogKeyOfSong:self.name artistKey:self.artistKey albumKey:self.albumKey]];
        
    }
    return self;
}



// overloading getters

- (NSString*)genre
{
    return [self.mediaItem valueForProperty:MPMediaItemPropertyGenre]; 
}


- (NSTimeInterval)playbackDuration
{
    return [[self.mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
}


- (NSUInteger)albumTrackNumber
{
    return [[self.mediaItem valueForProperty:MPMediaItemPropertyAlbumTrackNumber] integerValue];
}


- (NSUInteger)albumTrackCount
{
    return [[self.mediaItem valueForProperty:MPMediaItemPropertyAlbumTrackCount] integerValue];
}


- (MPMediaItemArtwork*)artwork
{
    return [self.mediaItem valueForProperty:MPMediaItemPropertyArtwork]; 
}


- (NSUInteger)rating
{
    return [[self.mediaItem valueForProperty:MPMediaItemPropertyRating] integerValue];
}





@end



