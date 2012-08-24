//
//  SongLocal.h
//  Yasound
//
//  Created by loïc berthelot.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Song.h"
#import <MediaPlayer/MediaPlayer.h>


@interface SongLocal : Song

// radio id which the song is uploaded to
@property (nonatomic, retain) NSNumber* radio_id;

@property (nonatomic, retain) MPMediaItem* mediaItem;
@property (nonatomic, retain) NSString* catalogKey;

@property (nonatomic, retain) NSString* artistKey;
@property (nonatomic, retain) NSString* albumKey;

//@property (nonatomic, retain) UIImage* cover;


@property (nonatomic, retain) NSString* genre;
@property (nonatomic) NSTimeInterval playbackDuration; 
@property (nonatomic) NSUInteger albumTrackNumber;
@property (nonatomic) NSUInteger albumTrackCount;
@property (nonatomic, retain) MPMediaItemArtwork* artwork;
@property (nonatomic) NSUInteger rating;


- (id)initWithMediaItem:(MPMediaItem*)mediaItem;



@end

