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
      _request = nil;
  }
  return self;
}


- (void) dealloc
{
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






#pragma mark - YasoundDataProvider callbacks

- (void)onUploadDidFinish:(NSString*)msg withInfos:(NSDictionary*)info
{
  NSError *error;
  NSFileManager *fileMgr = [NSFileManager defaultManager];
  [fileMgr removeItemAtPath:_tempSongFile error:&error];

    [_target performSelector:_selector withObject:info];
    
    [_request clearDelegatesAndCancel];
    [_request release];
}




#pragma mark - public functions

- (BOOL)uploadSong:(NSString*)title forRadioId:(NSNumber*)radio_id album:(NSString*)album artist:(NSString *)artist songId:(NSNumber*)songId target:(id)target action:(SEL)selector progressDelegate:(id)progressDelegate
{
  MPMediaItem *item = [self findSong:title album:album artist:artist];
  if (!item) 
    return FALSE;

    
  _target = target;
  _selector = selector;

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
  
  //DLog(@"SongUploader %@", fullPath);
    
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
        [self onUploadDidFinish:nil withInfos:info];

      return;
    }
    
    // import completed
    [import release];
    import = nil;  


        // LBDEBUG : is this data properly released? just make sure...
        
    NSData *data = [NSData dataWithContentsOfFile: fullPath];
    _request = [[YasoundDataProvider main] uploadSong:data  forRadioId:radio_id
                                     title:title
                                     album:album
                                    artist:artist 
                                    songId:songId target:self action:@selector(onUploadDidFinish:withInfos:) progressDelegate:progressDelegate];
        
  }];
  return TRUE;
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



- (BOOL)uploadSong:(SongUploading*)song target:(id)target action:(SEL)selector progressDelegate:(id)progressDelegate
{
    if (![song isKindOfClass:[SongUploading class]])
    {
        DLog(@"MEUH!");
        assert(0);
        return NO;
    }
    
    return [self uploadSong:song.songLocal.name_client forRadioId:song.radio_id album:song.songLocal.album_client artist:song.songLocal.artist_client songId:song.songLocal.id target:target action:selector progressDelegate:progressDelegate];
}

- (BOOL)canUploadSong:(Song*)song
{
    return [self canUploadSong:song.name album:song.album artist:song.artist];
}



- (void)cancelSongUpload
{
    // request may be nil, if the upload has been canceled because the file is incorrect for instance
    if (_request != nil)
    {
        [_request clearDelegatesAndCancel];
        [_request release];
    }
}




@end
