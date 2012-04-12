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

- (void)songUploadDidStart:(Song*)song;
- (void)songUploadDidInterrupt:(Song*)song;
- (void)songUploadProgress:(Song*)song progress:(CGFloat)progress;
- (void)songUploadDidFinish:(Song*)song info:(NSDictionary*)info;

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

@property (nonatomic, retain) Song* song;
@property (nonatomic) CGFloat currentProgress;
@property (nonatomic) SongUploadItemStatus status;
@property (nonatomic, retain) NSString* detailedInfo;
@property (nonatomic, retain) id<SongUploadItemDelegate> delegate;
//@property (nonatomic, retain) SongUploader* uploader;


- (id)initWithSong:(Song*)aSong;
- (void)startUpload;
- (void)cancelUpload; // interrupt and remove

- (void)interruptUpload; // interrupt only

@end






@interface SongUploadManager : NSObject

@property (atomic, retain, readonly) NSMutableArray* items;
@property (nonatomic)  BOOL isRunning;
@property (nonatomic) BOOL notified3G;


+ (SongUploadManager*)main;

- (void)addSong:(Song*)song startUploadNow:(BOOL)startUploadNow;
- (void)importUploads;
- (void)clearStoredUpdloads;

- (void)interruptUploads;
- (void)resumeUploads;

- (Song*)getUploadingSong:(NSString*)name artist:(NSString*)artist album:(NSString*)album;


@end
