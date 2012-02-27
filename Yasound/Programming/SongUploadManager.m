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
    [_uploader uploadSong:self.song target:self action:@selector(uploadDidFinish) progressDelegate:self];
                 
    if (self.delegate != nil)
        [self.delegate songUploadDidStart:song];
}

- (void)uploadDidFinish
{
    if (self.delegate != nil)
        [self.delegate songUploadDidFinish:song];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_DIDFINISH object:self];
}


#pragma mark - Progress Delegate

- (void)setProgress:(float)newProgress
{
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotification:) name:NOTIF_UPLOAD_DIDFINISH object:nil];
    }
    return self;
}



- (void)addAndUploadSong:(Song*)song
{
    SongUploadManagerItem* item = [[SongUploadManagerItem alloc] initWithSong:song];
    [_items addObject:item];
    
    if (self.items.count == 1)
        [self loop];
}


- (void)loop
{
    SongUploadManagerItem* item = [self.items objectAtIndex:self.index];
    //LBDEBUG
//    [item startUpload];
}


- (void)onNotification:(NSNotification *)notification
{
    // move to the next item
    _index++;
    
    [self loop];
}


@end
