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
  }
  return self;
}


- (void) dealloc
{
  if (_tempSongFile) 
    [_tempSongFile release];

}



-(MPMediaItem *)findSong:(NSString*)title album:(NSString*)album artist:(NSString *)artist
{
  MPMediaPropertyPredicate *artistPredicate = [MPMediaPropertyPredicate predicateWithValue:artist forProperty: MPMediaItemPropertyArtist];
  MPMediaPropertyPredicate *albumPredicate = [MPMediaPropertyPredicate predicateWithValue:album forProperty: MPMediaItemPropertyAlbumTitle];
  MPMediaPropertyPredicate *titlePredicate = [MPMediaPropertyPredicate predicateWithValue:title forProperty: MPMediaItemPropertyTitle];
    
  MPMediaQuery *query = [[MPMediaQuery alloc] init];
  [query addFilterPredicate:artistPredicate];
  [query addFilterPredicate:albumPredicate];
  [query addFilterPredicate:titlePredicate];
  
  for (MPMediaItem* item in query.items) 
  {
    NSString* aTitle = [item valueForProperty:MPMediaItemPropertyTitle];
    NSString* aArtist = [item valueForProperty:MPMediaItemPropertyArtist];
    NSString* aAlbum = [item valueForProperty:MPMediaItemPropertyAlbumTitle];

      if ([title isEqualToString:aTitle] &&
        [artist isEqualToString:aArtist] &&
        [album isEqualToString:aAlbum]) {
      
      [query release];
      return item;
    }
  }
    
  [query release];
  return NULL;
}







#pragma mark - YasoundDataProvider callbacks

- (void)onUploadFinished:(NSString*)msg withInfos:(NSDictionary*)info
{
  NSError *error;
  NSFileManager *fileMgr = [NSFileManager defaultManager];
  [fileMgr removeItemAtPath:_tempSongFile error:&error];

  [_target performSelector:_selector];
}





#pragma mark - public functions

- (BOOL)uploadSong:(NSString*)title album:(NSString*)album artist:(NSString *)artist songId:(NSNumber*)songId target:(id)target action:(SEL)selector progressDelegate:(id)progressDelegate
{
  MPMediaItem *item = [self findSong:title album:album artist:artist];
  if (!item) 
    return FALSE;

    
  _target = target;
  _selector = selector;

  NSURL *assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
  if (assetURL == nil) 
  {
    NSLog(@"assertURL is nil for %@", item);
    return FALSE;
  }
  
  NSString* ext = [TSLibraryImport extensionForAssetURL:assetURL];
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  
  NSString *filename = [NSString stringWithFormat:@"%@.%@", title, ext];
  NSString *fullPath = [documentsDirectory stringByAppendingPathComponent: filename];
  
  NSError *error;
  NSFileManager *fileMgr = [NSFileManager defaultManager];
  [fileMgr removeItemAtPath:fullPath error:&error];
  
  if (_tempSongFile)
    [_tempSongFile release];

    _tempSongFile = [[NSString alloc] initWithString:fullPath];
    
  NSURL* outURL = [[NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:title]] URLByAppendingPathExtension:ext];    
  
  TSLibraryImport* import = [[TSLibraryImport alloc] init];
  [import importAsset:assetURL toURL:outURL completionBlock:^(TSLibraryImport* import) 
    {
    if (import.status != AVAssetExportSessionStatusCompleted) 
    {
      // something went wrong with the import
      NSLog(@"Error importing: %@", import.error);
      [import release];
      import = nil;
      return;
    }
    
    // import completed
    [import release];
    import = nil;  
    
    NSData *data = [NSData dataWithContentsOfFile: fullPath];
    [[YasoundDataProvider main] uploadSong:data 
                                     title:title
                                     album:album
                                    artist:artist 
                                    songId:songId target:self action:@selector(onUploadFinished:withInfos:) progressDelegate:progressDelegate];
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



- (BOOL)uploadSong:(Song*)song target:(id)target action:(SEL)selector progressDelegate:(id)progressDelegate
{
    return [self uploadSong:song.name album:song.album artist:song.artist songId:song.id target:target action:selector progressDelegate:progressDelegate];
}

- (BOOL)canUploadSong:(Song*)song
{
    return [self canUploadSong:song.name album:song.album artist:song.artist];
}




@end
