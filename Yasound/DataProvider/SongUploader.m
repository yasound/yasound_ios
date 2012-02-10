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
  if (self) {
    _tempSongFile = nil;
  }
  return self;
}

- (void) dealloc
{
  if (_tempSongFile) {
    [_tempSongFile release];
  }
}

-(MPMediaItem *)findSong:(NSString*)title album:(NSString*)album artist:(NSString *)artist
{
  MPMediaQuery *query = [MPMediaQuery songsQuery];
  for (MPMediaItem* item in query.items) {
    NSString* aTitle = [item valueForProperty:MPMediaItemPropertyTitle];
    NSString* aArtist = [item valueForProperty:MPMediaItemPropertyArtist];
    NSString* aAlbum = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
    if ([title isEqualToString:aTitle] &&
        [artist isEqualToString:aArtist] &&
        [album isEqualToString:aAlbum]) {
      return item;
    }
  }
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

- (BOOL)uploadSong:(NSString*)title album:(NSString*)album artist:(NSString *)artist target:(id)target action:(SEL)selector
{
  MPMediaItem *item = [self findSong:title album:album artist:artist];
  if (!item) {
    return FALSE;
  }
  
  _target = target;
  _selector = selector;

  NSURL *assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
  NSString* ext = [TSLibraryImport extensionForAssetURL:assetURL];
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  
  NSString *filename = [NSString stringWithFormat:@"%@.%@", title, ext];
  NSString *fullPath = [documentsDirectory stringByAppendingPathComponent: filename];
  
  NSError *error;
  NSFileManager *fileMgr = [NSFileManager defaultManager];
  [fileMgr removeItemAtPath:fullPath error:&error];
  
  if (_tempSongFile) {
    [_tempSongFile release];
  }
  _tempSongFile = [[NSString alloc] initWithString:fullPath];
    
  NSURL* outURL = [[NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:title]] URLByAppendingPathExtension:ext];    
  
  TSLibraryImport* import = [[TSLibraryImport alloc] init];
  [import importAsset:assetURL toURL:outURL completionBlock:^(TSLibraryImport* import) {
    if (import.status != AVAssetExportSessionStatusCompleted) {
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
    [[YasoundDataProvider main] uploadSong:data target:self action:@selector(onUploadFinished:withInfos:)];
  }];
  return TRUE;
}





@end
