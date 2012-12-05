//
//  SongUploader.m
//  Yasound
//
//  Created by Jérôme BLONDON on 08/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongUploader.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "TSLibraryImport.h"

#import "YasoundDataProvider.h"
#import "SongCatalog.h"
#import "ASIFormDataRequest.h"

@implementation SongUploader

static SongUploader* _main = nil;


+ (SongUploader*)main
{
  if (_main == nil)
  {
    _main = [[SongUploader alloc] init];
  }
  
  return _main;
}


- (id)init
{
  self = [super init];
  if (self) 
  {
      _tempSongFile = nil;
      _yarequest = nil;
  }
  return self;
}


- (void) dealloc
{
    if (_yarequest)
        [self clearRequest];
  if (_tempSongFile) 
    [_tempSongFile release];

    DLog(@"SongUploader dealloc");
    
    [super dealloc];
}



-(MPMediaItem *)findSong:(NSString*)title album:(NSString*)album artist:(NSString *)artist
{
    MPMediaPropertyPredicate *artistPredicate = nil;
    if ((artist != nil) && (artist.length > 0))
         artistPredicate = [MPMediaPropertyPredicate predicateWithValue:artist forProperty: MPMediaItemPropertyArtist];
    MPMediaPropertyPredicate *albumPredicate = nil;
    if ((album != nil) && (album.length > 0))
         albumPredicate = [MPMediaPropertyPredicate predicateWithValue:album forProperty: MPMediaItemPropertyAlbumTitle];
  MPMediaPropertyPredicate *titlePredicate = [MPMediaPropertyPredicate predicateWithValue:title forProperty: MPMediaItemPropertyTitle];
    
  MPMediaQuery *query = [[MPMediaQuery alloc] init];
    
    if (artistPredicate)
        [query addFilterPredicate:artistPredicate];
    if (albumPredicate)
        [query addFilterPredicate:albumPredicate];
  [query addFilterPredicate:titlePredicate];
  
  for (MPMediaItem* item in query.items) 
  {
    NSString* aTitle = [item valueForProperty:MPMediaItemPropertyTitle];

      BOOL res = [title isEqualToString:aTitle];
      if (artistPredicate)
      {
          NSString* aArtist = [item valueForProperty:MPMediaItemPropertyArtist];
          res &= [artist isEqualToString:aArtist];
      }
      if (albumPredicate)
      {
          NSString* aAlbum = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
          res &= [album isEqualToString:aAlbum];
      }

      if (res)
      {
          [query release];
          return item;
      }
  }
    
  [query release];
  return NULL;
}


#pragma mark - public functions

- (BOOL)uploadSong:(NSString*)title forRadioId:(NSNumber*)radio_id album:(NSString*)album artist:(NSString *)artist songId:(NSNumber*)songId completionBLock:(YaRequestCompletionBlock)completionBlock progressBlock:(YaRequestProgressBlock)progressBlock
{
    MPMediaItem *item = [self findSong:title album:album artist:artist];
    if (!item)
        return FALSE;
    
    NSURL *assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
    if (assetURL == nil)
    {
        DLog(@"assertURL is nil for %@", item);
        return FALSE;
    }
    
    NSString* ext = [TSLibraryImport extensionForAssetURL:assetURL];
    
    // store the tmp file in Cache directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cacheDirectory = [paths objectAtIndex:0];
    
    // get a unique and safe filename for the temp file
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
	CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
	NSString* fullPath = [cacheDirectory stringByAppendingPathComponent:(NSString *)newUniqueIdString];
    fullPath = [fullPath stringByAppendingPathExtension:ext];
    
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError *error;
    [fileMgr removeItemAtPath:fullPath error:&error];
    
    if (_tempSongFile)
        [_tempSongFile release];
    _tempSongFile = [[NSString alloc] initWithFormat:fullPath];
    
    NSURL* outURL = [NSURL fileURLWithPath:fullPath];
    
    TSLibraryImport* import = [[TSLibraryImport alloc] init];
    [import importAsset:assetURL toURL:outURL completionBlock:^(TSLibraryImport* import)
     {
         
         if (import.status != AVAssetExportSessionStatusCompleted)
         {
             // something went wrong with the import
             DLog(@"Error importing: %@", import.error);
             [import release];
             import = nil;
             
             // client callback
             NSMutableDictionary* info = [NSMutableDictionary dictionary];
             [info setObject:[NSNumber numberWithBool:NO] forKey:@"succeeded"];
             [info setObject:[NSString stringWithString:@"SongUpload_failedIncorrectFile"] forKey:@"detailedInfo"];
             
             if (completionBlock)
                 completionBlock(0, nil, [NSError errorWithDomain:@"cannot import song" code:1 userInfo:nil]);
             return;
         }
         
         // import completed
         [import release];
         import = nil;
         
         
         // LBDEBUG : is this data properly released? just make sure...
         
         NSData *data = [NSData dataWithContentsOfFile: fullPath];
         YaRequestCompletionBlock internalCompletionBlock = ^(int status, NSString* response, NSError* error){
             if (_yarequest)
                 [self clearRequest];
             if (completionBlock)
                 completionBlock(status, response, error);
         };
         
         _yarequest = [[YasoundDataProvider main] uploadSong:data forRadioId:radio_id
                                                       title:title
                                                       album:album
                                                      artist:artist
                                                      songId:songId
                                         withCompletionBlock:internalCompletionBlock
                                            andProgressBlock:progressBlock];
         [_yarequest retain];
         
     }];
    return TRUE;
}

- (void)cancelRequest
{
    [_yarequest cancel];
}

- (void)clearRequest
{
    [_yarequest release];
    _yarequest = nil;
}

- (BOOL)canUploadSong:(NSString*)title album:(NSString*)album artist:(NSString *)artist
{
    MPMediaItem *item = [self findSong:title album:album artist:artist];
    if (!item) 
        return FALSE;

    NSURL *assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
    if (assetURL == nil) 
        return FALSE;

    return TRUE;
}

- (BOOL)uploadSong:(SongUploading*)song forRadioId:(NSNumber*)radio_id completionBlock:(YaRequestCompletionBlock)completionBlock progressBlock:(YaRequestProgressBlock)progressBlock
{
    if (![song isKindOfClass:[SongUploading class]])
    {
        assert(0);
        return NO;
    }
    
    return [self uploadSong:song.songLocal.name_client forRadioId:song.radio_id album:song.songLocal.album_client artist:song.songLocal.artist_client songId:song.songLocal.id completionBLock:completionBlock progressBlock:progressBlock];
}


- (BOOL)canUploadSong:(Song*)song
{
    return [self canUploadSong:song.name album:song.album artist:song.artist];
}



- (void)cancelSongUpload
{
    // request may be nil, if the upload has been canceled because the file is incorrect for instance
    if (_yarequest != nil)
    {
        [self cancelRequest];
        [self clearRequest];
    }
}




@end
