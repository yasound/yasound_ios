//
//  SongUploadManager.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Song.h"
#import "SongUploader.h"

/*
    A SIMPLE HOWTO :
 
1-
    SongUploadManager handles an array of items (SongUploadManagerItem).
 
 
2-
    -----------------------------------------------------
    BOOL can = [[SongUploader main] canUploadSong:mySong];
    if (!can)
    return;

    // add an upload job to the queue
    [[SongUploadManager main] addAndUploadSong:mySong];


3- 
    -----------------------------------------------------
    somewhere else (maybe), in GUI controller:

    // returns the list of current and pending jobs
    [SongUploadManager main].items 

    // for instance, in a custom UITableViewCell:
    SongUploadManagerItem* uploader = [[SongUploadManager main].items objectAtIndex:cellIndexPath.row];
    uploader.delegate = self;

    // implements protocol's delegates here
    ...
 
 
*/





@protocol SongUploadManagerItemDelegate <NSObject>
@required

- (void)songUploadDidStart:(Song*)song;
- (void)songUploadProgress:(Song*)song progress:(CGFloat)progress;
- (void)songUploadDidFinish:(Song*)song info:(NSDictionary*)info;

@end



@interface SongUploadManagerItem : NSObject
{
    SongUploader* _uploader;
    
}

@property (nonatomic, retain) Song* song;
@property (nonatomic) CGFloat currentProgress;
@property (nonatomic, retain) id<SongUploadManagerItemDelegate> delegate;

- (id)initWithSong:(Song*)aSong;
- (void)startUpload;

@end






@interface SongUploadManager : NSObject
{
    BOOL _uploading;
}

@property (atomic, retain, readonly) NSMutableArray* items;
@property (nonatomic, readonly) NSInteger index;

+ (SongUploadManager*)main;

- (void)addAndUploadSong:(Song*)song;


@end
