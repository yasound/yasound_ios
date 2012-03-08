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

- (void)cancelUpload
{
    [_uploader cancelSongUpload:self.song];
    
    [self.song setUploading:NO];

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_DIDCANCEL object:self];
}

- (void)interruptUpload
{
    if (self.status != SongUploadItemStatusUploading)
        return;
    
    [self.song setUploading:NO];
    self.status = SongUploadItemStatusPending;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_DIDINTERRUPT object:self];
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
        
        // ne pas faire ça tout de suite
        // attendre de voir comment on gère la reprise 'dun upload e´choué
        // [self.song setUploading:NO];

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
@synthesize interrupted;
//@synthesize index = _index;
//@synthesize currentlyUploadingItem = _currentlyUploadingItem;

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
        self.interrupted = NO;
//        _index = 0;
//        _uploading = NO;
//        _currentlyUploadingItem = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationFinish:) name:NOTIF_UPLOAD_DIDFINISH object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationCancel:) name:NOTIF_UPLOAD_DIDCANCEL object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationInterrupt:) name:NOTIF_UPLOAD_DIDINTERRUPT object:nil];
        
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

// store pending and uploading songs in user defaults in order to restart the uncompleted ones at next login
- (void)refreshStoredUploads
{
  NSMutableArray* newUploads = [NSMutableArray array];
  for (SongUploadItem* item in self.items) 
  {
    SongUploadItemStatus status = item.status;
    if (status == SongUploadItemStatusPending || status == SongUploadItemStatusUploading)
    {
      Song* song = item.song;
      NSMutableDictionary* songInfo = [NSMutableDictionary dictionary];
      [songInfo setValue:song.name forKey:@"name"];
      [songInfo setValue:song.artist forKey:@"artist"];
      [songInfo setValue:song.album forKey:@"album"];
      [newUploads addObject:songInfo];
    }
  }
  [[NSUserDefaults standardUserDefaults] setObject:newUploads forKey:SONG_UPLOADS_DEFAULTS_ENTRY_NAME];
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
        [self addSong:s startUploadNow:YES];
    }
  }
}

- (void)clearStoredUpdloads
{
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:SONG_UPLOADS_DEFAULTS_ENTRY_NAME];
  [[NSUserDefaults standardUserDefaults] synchronize];
}



- (void)interruptUploads
{
    self.interrupted = YES;
    for (SongUploadItem* item in self.items)
        [item interruptUpload];
}

- (void)resumeUploads
{
    self.interrupted = NO;
    [self loop];
}




- (void)addSong:(Song*)song startUploadNow:(BOOL)startUploadNow
{
    SongUploadItem* item = [[SongUploadItem alloc] initWithSong:song];
    [_items addObject:item];

    if (startUploadNow)
        [self loop];
  
  [self refreshStoredUploads]; // store song upload in user defaults in order to resume it if the application exits before completion
}


- (Song*)getUploadingSong:(NSString*)name artist:(NSString*)artist album:(NSString*)album
{
    for (SongUploadItem* item in self.items)
    {
        NSString* verif = item.song.name;
        if (![verif isEqualToString:name])
            continue;
        
        verif = item.song.album;
        if (![verif isEqualToString:album])
            continue;

        verif = item.song.artist;
        if (![verif isEqualToString:artist])
            continue;
        
        return item.song;
}
    
    return nil;
}



- (void)loop
{
//    _uploading = YES;
    
    // check if an item is currently uploading
    // if not, start the upload
    
    for (SongUploadItem* item in self.items)
    {
        if ((item.status == SongUploadItemStatusCompleted) || (item.status == SongUploadItemStatusFailed))
            continue;
        
        // an item is currently uploading. Wait for it to finish before starting another upload.
        if (item.status == SongUploadItemStatusUploading)
            return;
            
        // start another upload
        if (item.status == SongUploadItemStatusPending)
        {
            [item startUpload];
            return;
        }
    }
}


- (void)onNotificationFinish:(NSNotification *)notification
{  
    // move to the next item
//    _index++;
    
    [self loop];
//    else
//        _uploading = NO;
  
  [self refreshStoredUploads];
}

- (void)onNotificationCancel:(NSNotification *)notification
{
    SongUploadItem* item = notification.object;
    assert(item != nil);
    
    BOOL found = NO;
    NSInteger itemIndex = 0;
    for (itemIndex = 0; itemIndex < self.items.count; itemIndex++)
    {
        SongUploadItem* anItem = [self.items objectAtIndex:itemIndex];
        
        if (anItem == item)
        {
            found = YES;
            break;
        }
    }
    
    assert(found == YES);
    
    [self.items removeObjectAtIndex:itemIndex];

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_DIDCANCEL_NEEDGUIREFRESH object:self];

    // move to the next item,
    // dont need to increment since we deleted the current item
    //_index++;
    
//    if (_index < self.items.count)
        [self loop];
//    else
//        _uploading = NO;
    
  [self refreshStoredUploads];
}





- (void)onNotificationInterrupt:(NSNotification *)notification
{
//    SongUploadItem* item = notification.object;
//    assert(item != nil);
//    
//    BOOL found = NO;
//    NSInteger itemIndex = 0;
//    for (itemIndex = 0; itemIndex < self.items.count; itemIndex++)
//    {
//        SongUploadItem* anItem = [self.items objectAtIndex:itemIndex];
//        
//        if (anItem == item)
//        {
//            found = YES;
//            break;
//        }
//    }
//    
//    assert(found == YES);
//    
//    [self.items removeObjectAtIndex:itemIndex];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_DIDCANCEL_NEEDGUIREFRESH object:self];
//    
//    // move to the next item,
//    // dont need to increment since we deleted the current item
//    //_index++;
//    
//    //    if (_index < self.items.count)
//    [self loop];
//    //    else
//    //        _uploading = NO;
//    
//    [self refreshStoredUploads];
}






@end
