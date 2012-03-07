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
        self.name = [item valueForProperty:MPMediaItemPropertyTitle];
        
        self.artistKey = [item valueForProperty:MPMediaItemPropertyArtist];
        self.albumKey = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
        
        
        self.genre = [item valueForProperty:MPMediaItemPropertyGenre]; 
        self.playbackDuration = [[item valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
        self.albumTrackNumber = [[item valueForProperty:MPMediaItemPropertyAlbumTrackNumber] integerValue];
        self.albumTrackCount = [[item valueForProperty:MPMediaItemPropertyAlbumTrackCount] integerValue];
        self.artwork = [item valueForProperty:MPMediaItemPropertyArtwork]; 
        self.rating = [[item valueForProperty:MPMediaItemPropertyRating] integerValue];
        
        
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


@end



