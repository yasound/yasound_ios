//
//  SongUploadManager.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SongLocal.h"
#import "SongUploader.h"

/*
    A SIMPLE HOWTO :
 
1-
    SongUploadManager handles an array of items (SongUploadItem).
 
 
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
    SongUploadItem* uploader = [[SongUploadManager main].items objectAtIndex:cellIndexPath.row];
    uploader.delegate = self;

    // implements protocol's delegates here
    ...
 
 
*/



#define NOTIF_UPLOAD_DIDFINISH @"NOTIF_UploadDidFinish"
#define NOTIF_UPLOAD_DIDCANCEL @"NOTIF_UploadDidCancel"
#define NOTIF_UPLOAD_DIDINTERRUPT @"NOTIF_UploadDidInterrupt"

#define NOTIF_SONG_GUI_NEED_REFRESH @"NOTIF_GuiNeedRefresh"

#define NOTIF_UPLOAD_DIDSUCCEED @"NOTIF_UploadDidSucceed"
#define NOTIF_UPLOAD_DIDFAIL @"NOTIF_UploadDidFail"




@protocol SongUploadItemDelegate <NSObject>
@required

- (void)songUploadDidStart:(SongLocal*)song;
- (void)songUploadDidInterrupt:(SongLocal*)song;
- (void)songUploadProgress:(SongLocal*)song progress:(CGFloat)progress bytes:(NSUInteger)bytes;
- (void)songUploadDidFinish:(SongLocal*)song info:(NSDictionary*)info;

@end

typedef enum SongUploadItemStatus 
{
	SongUploadItemStatusPending = 0,
	SongUploadItemStatusUploading = 1,
	SongUploadItemStatusCompleted = 2,
	SongUploadItemStatusFailed = 3
} SongUploadItemStatus;



@interface SongUploadItem : NSObject
{
    SongUploader* _uploader;
}

@property (nonatomic, retain) SongLocal* song;
@property (nonatomic) CGFloat currentProgress;
@property (nonatomic) NSUInteger currentSize;
@property (nonatomic) SongUploadItemStatus status;
@property (nonatomic) NSInteger nbFails;
@property (nonatomic, retain) NSString* detailedInfo;
@property (nonatomic, retain) id<SongUploadItemDelegate> delegate;
//@property (nonatomic, retain) SongUploader* uploader;


- (id)initWithSong:(SongLocal*)aSong;
- (void)startUpload;
- (void)cancelUpload; // interrupt and remove

- (void)interruptUpload; // interrupt only

@end






@interface SongUploadManager : NSObject

@property (atomic, retain, readonly) NSMutableArray* items;
@property (nonatomic)  BOOL isRunning;
@property (nonatomic) BOOL notified3G;


+ (SongUploadManager*)main;

- (void)addSong:(SongLocal*)song startUploadNow:(BOOL)startUploadNow;
- (void)importUploads;
- (void)clearStoredUpdloads;

- (void)interruptUploads;
- (void)resumeUploads;

- (SongLocal*)getUploadingSong:(NSString*)name artist:(NSString*)artist album:(NSString*)album;


@end
