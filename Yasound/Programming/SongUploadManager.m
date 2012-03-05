//
//  SongUploadManager.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongUploadManager.h"





@implementation SongUploadItem

@synthesize song;
@synthesize currentProgress;
@synthesize delegate;
@synthesize status;


- (id)initWithSong:(Song*)aSong
{
    if (self = [super init])
    {   
        self.song = aSong;
        self.status = SongUploadItemStatusPending;
    }
    return self;
}


- (void)startUpload
{
    self.status = SongUploadItemStatusUploading;
    
    _uploader = [[SongUploader alloc] init];
    [_uploader uploadSong:self.song target:self action:@selector(uploadDidFinished:) progressDelegate:self];
                
    self.currentProgress = 0;
    
    if (self.delegate != nil)
        [self.delegate songUploadDidStart:song];
}

- (void)uploadDidFinished:(NSDictionary*)info
{
    NSNumber* succeeded = [info objectForKey:@"succeeded"];
    assert(succeeded != nil);
    
    if ([succeeded boolValue])
    {
        self.status = SongUploadItemStatusCompleted;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_DIDSUCCEED object:self];
    }
    else
    {
        self.status = SongUploadItemStatusFailed;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_DIDFAIL object:self];
    }
    
    if (self.delegate != nil)
        [self.delegate songUploadDidFinish:song info:info];
    
    // send notif to ask the manager to continue with the upload list
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_DIDFINISH object:self];
    
    // send notif to warn the list handlers to update, depending on the request's result
}


#pragma mark - Progress Delegate

- (void)setProgress:(float)newProgress
{
    self.currentProgress = newProgress;

    if (self.delegate != nil)
        [self.delegate songUploadProgress:self.song progress:newProgress];
}


@end





#define SONG_UPLOADS_DEFAULTS_ENTRY_NAME @"SongUploads"



@implementation SongUploadManager

@synthesize items = _items;
@synthesize index = _index;


static SongUploadManager* _main;

+ (SongUploadManager*)main
{
    if (_main == nil)
    {
        _main = [[SongUploadManager alloc] init];
    }
    return _main;
}


- (id)init
{
    if (self = [super init])
    {
        _items = [[NSMutableArray alloc] init];
        _index = 0;
        _uploading = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotification:) name:NOTIF_UPLOAD_DIDFINISH object:nil];
    }
    return self;
}


// get the list of song upload info stored in user defaults
- (NSArray*)storedSongsToUpload
{
  NSMutableArray* storedUploads = [[NSUserDefaults standardUserDefaults] objectForKey:SONG_UPLOADS_DEFAULTS_ENTRY_NAME];
  if (!storedUploads)
    return nil;
  
  NSMutableArray* songs = [NSMutableArray arrayWithCapacity:storedUploads.count];
  
  for (NSDictionary* songInfo in storedUploads) 
  {
    NSString* storedName = [songInfo valueForKey:@"name"];
    NSString* storedArtist = [songInfo valueForKey:@"artist"];
    NSString* storedAlbum = [songInfo valueForKey:@"album"];
    Song* s = [[Song alloc] init];
    s.name = storedName;
    s.artist = storedArtist;
    s.album = storedAlbum;
    [s setUploading:YES];
    
    [songs addObject:s];
  }
  return songs;
}

// store song upload info in user defaults
- (void)storeUpload:(Song*)song
{
  NSArray* storedUploads = [[NSUserDefaults standardUserDefaults] objectForKey:SONG_UPLOADS_DEFAULTS_ENTRY_NAME];
  NSMutableArray* newUploads = nil;
  if (!storedUploads)
    newUploads = [NSMutableArray array];
  else
    newUploads = [NSMutableArray arrayWithArray:storedUploads];
  
  NSMutableDictionary* songInfo = [NSMutableDictionary dictionary];
  [songInfo setValue:song.name forKey:@"name"];
  [songInfo setValue:song.artist forKey:@"artist"];
  [songInfo setValue:song.album forKey:@"album"];
  [newUploads addObject:songInfo];
  
  [[NSUserDefaults standardUserDefaults] setObject:newUploads forKey:SONG_UPLOADS_DEFAULTS_ENTRY_NAME];
  [[NSUserDefaults standardUserDefaults] synchronize];        
}

// remove song upload info from user defaults
- (void)releaseUpload:(Song*)song
{
  NSArray* storedUploads = [[NSUserDefaults standardUserDefaults] objectForKey:SONG_UPLOADS_DEFAULTS_ENTRY_NAME];
  if (!storedUploads)
    return;
  
  NSDictionary* toremove = nil;
  for (NSDictionary* songInfo in storedUploads) 
  {
    NSString* storedName = [songInfo valueForKey:@"name"];
    NSString* storedArtist = [songInfo valueForKey:@"artist"];
    NSString* storedAlbum = [songInfo valueForKey:@"album"];
    if ([song.name isEqualToString:storedName] && [song.artist isEqualToString:storedArtist] && [song.album isEqualToString:storedAlbum])
    {
      toremove = songInfo;
      break;
    }
  }
  
  NSMutableArray* uploads = [NSMutableArray arrayWithArray:storedUploads];
  if (toremove)
    [uploads removeObject:toremove];
  
  [[NSUserDefaults standardUserDefaults] setObject:uploads forKey:SONG_UPLOADS_DEFAULTS_ENTRY_NAME];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)restartUploads
{
  // get song info of all non-completed uploads from previous application session
  NSArray* storedSongs = [self storedSongsToUpload];
  
  [self clearStoredUpdloads];
  
  if (storedSongs)
  {
    for (Song* s  in storedSongs) 
    {
      [self addAndUploadSong:s];
    }
  }
}

- (void)clearStoredUpdloads
{
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:SONG_UPLOADS_DEFAULTS_ENTRY_NAME];
  [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)addAndUploadSong:(Song*)song
{
    SongUploadItem* item = [[SongUploadItem alloc] initWithSong:song];
    [_items addObject:item];
    
    if (!_uploading)
        [self loop];
  
  [self storeUpload:song]; // store song upload in user defaults in order to resume it if the application exits before completion
}


- (void)loop
{
    _uploading = YES;
    
    SongUploadItem* item = [self.items objectAtIndex:self.index];
    [item startUpload];
}


- (void)onNotification:(NSNotification *)notification
{
  SongUploadItem* finishedItem = [self.items objectAtIndex:_index];
  [self releaseUpload:finishedItem.song]; // remove song upload entry stored in user defaults
  
    // move to the next item
    _index++;
    
    if (_index < self.items.count)
        [self loop];
    else
        _uploading = NO;
}


@end
