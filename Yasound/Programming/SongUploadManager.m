//
//  SongUploadManager.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongUploadManager.h"


#define NOTIF_UPLOAD_DIDFINISH @"NOTIF_UploadDidFinish"



@implementation SongUploadManagerItem

@synthesize song;
@synthesize currentProgress;
@synthesize delegate;

- (id)initWithSong:(Song*)aSong
{
    if (self = [super init])
    {   
        self.song = aSong;
    }
    return self;
}


- (void)startUpload
{
    _uploader = [[SongUploader alloc] init];
    [_uploader uploadSong:self.song target:self action:@selector(uploadDidFinished:) progressDelegate:self];
                
    self.currentProgress = 0;
    
    if (self.delegate != nil)
        [self.delegate songUploadDidStart:song];
}

- (void)uploadDidFinished:(NSDictionary*)info
{
    if (self.delegate != nil)
        [self.delegate songUploadDidFinish:song info:info];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_DIDFINISH object:self];
}


#pragma mark - Progress Delegate

- (void)setProgress:(float)newProgress
{
    self.currentProgress = newProgress;

    if (self.delegate != nil)
        [self.delegate songUploadProgress:self.song progress:newProgress];
}


@end









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



- (void)addAndUploadSong:(Song*)song
{
    SongUploadManagerItem* item = [[SongUploadManagerItem alloc] initWithSong:song];
    [_items addObject:item];
    
    _index = _items.count - 1;
    
    if (!_uploading)
        [self loop];
}


- (void)loop
{
    _uploading = YES;
    
    SongUploadManagerItem* item = [self.items objectAtIndex:self.index];
    [item startUpload];
}


- (void)onNotification:(NSNotification *)notification
{
    // move to the next item
    _index++;
    
    if (_index < self.items.count)
        [self loop];
    else
        _uploading = NO;
}


@end
