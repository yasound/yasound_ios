//
//  SongUploadManager.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongUploadManager.h"

#import "YasoundReachability.h"



#define NB_FAILS_MAX 3


@implementation SongUploadItem

@synthesize song;
@synthesize currentProgress;
@synthesize currentSize;
@synthesize delegate;
@synthesize status;
@synthesize nbFails;
@synthesize detailedInfo;

- (id)initWithSong:(SongUploading*)aSong
{
    if (self = [super init])
    {
        if (![aSong isKindOfClass:[SongUploading class]])
        {
            assert(0);
            return self;
        }
        
        if (aSong.radio_id == nil)
        {
            assert(0);
            return self;
        }
            
        self.song = aSong;
        self.status = SongUploadItemStatusPending;
        self.nbFails = 0;
    }
    return self;
}


- (void)startUpload
{
    self.status = SongUploadItemStatusUploading;
    
    _uploader = [[SongUploader alloc] init];
    BOOL res = [_uploader uploadSong:self.song target:self action:@selector(uploadDidFinished:) progressDelegate:self];
    if (!res)
    {
        self.status = SongUploadItemStatusFailed;
        self.nbFails++;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_DIDFAIL object:self];
        return;
    }
        

    self.currentProgress = 0;
    self.currentSize = 0;
    
    if (self.delegate != nil)
        [self.delegate songUploadDidStart:song];
    
    
}

- (void)cancelUpload
{
    if (self.status == SongUploadItemStatusUploading)
    {
        [_uploader cancelSongUpload];
        [_uploader release];
        _uploader = nil;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_DIDCANCEL object:self];
}

- (void)interruptUpload
{
    if (self.status != SongUploadItemStatusUploading)
        return;
    
    self.status = SongUploadItemStatusPending;

    if (_uploader)
    {
        [_uploader cancelSongUpload];
        [_uploader release];
        _uploader = nil;
    }

    self.currentProgress = 0;
    self.currentSize = 0;

    if (self.delegate != nil)
        [self.delegate songUploadDidInterrupt:self.song];

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_DIDINTERRUPT object:self];
}



- (void)uploadDidFinished:(NSDictionary*)info
{
    NSNumber* succeeded = [info objectForKey:@"succeeded"];
    assert(succeeded != nil);
    self.detailedInfo = [info objectForKey:@"detailedInfo"];
    

    if ([succeeded boolValue])
    {
        self.status = SongUploadItemStatusCompleted;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_DIDSUCCEED object:self];
    }
    else
    {
 
        self.status = SongUploadItemStatusFailed;
        self.nbFails++;
        
        // ne pas faire ça tout de suite
        // attendre de voir comment on gère la reprise 'dun upload e´choué
        // [self.song setUploading:NO];

        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_DIDFAIL object:self];
    }
    
    if (self.delegate != nil)
        [self.delegate songUploadDidFinish:self.song info:info];
    
    // send notif to ask the manager to continue with the upload list
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_DIDFINISH object:self];
    
    // send notif to warn the list handlers to update, depending on the request's result
}


#pragma mark - Progress Delegate

- (void)setProgress:(float)newProgress
{
    self.currentProgress = newProgress;
    
    if (self.delegate != nil)
        [self.delegate songUploadProgress:self.song progress:newProgress bytes:self.currentSize];
}


- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
    self.currentSize += bytes;
}

@end








@implementation SongUploadManager

@synthesize items = _items;
@synthesize isRunning;
@synthesize notified3G;

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
        
        
        self.isRunning = YES;
        self.notified3G = NO;
        
        BOOL isWifi = ([YasoundReachability main].networkStatus == ReachableViaWiFi);
        self.isRunning = isWifi;
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationFinish:) name:NOTIF_UPLOAD_DIDFINISH object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationCancel:) name:NOTIF_UPLOAD_DIDCANCEL object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationInterrupt:) name:NOTIF_UPLOAD_DIDINTERRUPT object:nil];
        
    }
    return self;
}


// get the list of song upload info stored in user defaults
// NSArray of SongUploading*
- (NSArray*)storedSongsToUpload
{
    NSMutableArray* storedUploads = [[UserSettings main] mutableArrayForKey:USKEYuploadList];
  if (!storedUploads)
    return nil;
  
  NSMutableArray* songs = [NSMutableArray arrayWithCapacity:storedUploads.count];
  
  for (NSDictionary* songInfo in storedUploads) 
  {
    NSString* storedName = [songInfo valueForKey:@"name"];
      NSNumber* storedRadioId = [songInfo valueForKey:@"radio_id"];
    NSString* storedArtist = [songInfo valueForKey:@"artist"];
      NSString* storedAlbum = [songInfo valueForKey:@"album"];
      NSString* storedCatalogKey = [songInfo valueForKey:@"catalogKey"];
      
      if (storedRadioId == nil)
      {
          continue; // should mean that the upload had been registered with client v1, and we now work with client v2
                    // => abort the upload, sorry.
      }

      SongUploading* songUploading = [SongUploading new];
      songUploading.songLocal = [[SongLocal alloc] init];
      songUploading.radio_id = storedRadioId;
    songUploading.songLocal.name = storedName;
    songUploading.songLocal.artist = storedArtist;
    songUploading.songLocal.album = storedAlbum;
      songUploading.songLocal.name_client = storedName;
      songUploading.songLocal.artist_client = storedArtist;
      songUploading.songLocal.album_client = storedAlbum;
      songUploading.songLocal.catalogKey = storedCatalogKey;
      
    [songs addObject:songUploading];
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
    if ((status == SongUploadItemStatusPending)
         || (status == SongUploadItemStatusUploading)
         || ((status == SongUploadItemStatusFailed) && (item.nbFails < NB_FAILS_MAX))
        )
    {
        SongUploading* song = item.song;
        
      NSMutableDictionary* songInfo = [NSMutableDictionary dictionary];
      [songInfo setValue:song.songLocal.name forKey:@"name"];
        [songInfo setValue:song.radio_id forKey:@"radio_id"];
      [songInfo setValue:song.songLocal.artist forKey:@"artist"];
        [songInfo setValue:song.songLocal.album forKey:@"album"];
        [songInfo setValue:song.songLocal.catalogKey forKey:@"catalogKey"];
      [newUploads addObject:songInfo];
    }
  }
    [[UserSettings main] setObject:newUploads forKey:USKEYuploadList];
}

- (void)importUploads
{
  // get song info of all non-completed uploads from previous application session
  NSArray* storedSongs = [self storedSongsToUpload];
  
  [self clearStoredUpdloads];
  
  if (storedSongs)
  {
    for (SongUploading* s  in storedSongs)
    {
        [self addSong:s startUploadNow:NO];
    }
  }
}

- (void)clearStoredUpdloads
{
    [[UserSettings main] removeObjectForKey:USKEYuploadList];
}



- (void)interruptUploads
{
    self.isRunning = NO;
    for (SongUploadItem* item in self.items)
        [item interruptUpload];
}

- (void)resumeUploads
{
    self.isRunning = YES;
    [self loop];
}


- (NSInteger)countUploads {
    
    NSInteger count = 0;
    for (SongUploadItem* item in self.items) {
        
        if ((item.status == SongUploadItemStatusPending) || (item.status == SongUploadItemStatusUploading))
            count++;

    }
    return count;
}





- (void)addSong:(SongUploading*)song startUploadNow:(BOOL)startUploadNow
{
    SongUploadItem* item = [[SongUploadItem alloc] initWithSong:song];
    [_items addObject:item];

    if (startUploadNow)
        [self loop];
  
  [self refreshStoredUploads]; // store song upload in user defaults in order to resume it if the application exits before completion
}


- (SongUploading*)getUploadingSong:(NSString*)songKey forRadio:(Radio*)radio
{
    for (SongUploadItem* item in self.items)
    {
        if (![item.song.radio_id isEqualToNumber:radio.id])
            continue;
        
        NSString* verif = item.song.songLocal.catalogKey;
        if (![verif isEqualToString:songKey])
            continue;
        
        return item.song;
    }
    
    return nil;
}




- (void)loop
{
    if (!self.isRunning)
        return;
    
    // check if an item is currently uploading
    // if not, start the upload
    
    for (SongUploadItem* item in self.items)
    {
        if ((item.status == SongUploadItemStatusCompleted) || ((item.status == SongUploadItemStatusFailed) && (item.nbFails >= NB_FAILS_MAX)))
            continue;
        
        // an item is currently uploading. Wait for it to finish before starting another upload.
        if (item.status == SongUploadItemStatusUploading)
            return;
            
        // start another upload
        if ((item.status == SongUploadItemStatusPending) || (item.status == SongUploadItemStatusFailed))
        {
            [item startUpload];
            return;
        }
    }
    
}


- (void)onNotificationFinish:(NSNotification *)notification
{  
    [self refreshStoredUploads];
    
    [self loop];  
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
    
    //assert(found == YES);
    if (!found)
        return;
    
    [self.items removeObjectAtIndex:itemIndex];

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SONG_GUI_NEED_REFRESH object:self];

    
    [self loop];
    
    [self refreshStoredUploads];
}





- (void)onNotificationInterrupt:(NSNotification *)notification
{
}






@end
