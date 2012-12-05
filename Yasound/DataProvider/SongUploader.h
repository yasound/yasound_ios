//
//  SongUploader.h
//  Yasound
//
//  Created by Jérôme BLONDON on 08/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
#import "YasoundDataProvider.h"
#import "SongUploading.h"


@interface SongUploader : NSObject 
{
  NSString* _tempSongFile;
    YaRequest* _yarequest;
  id _target;
  SEL _selector;
}


+ (SongUploader*)main;



//- (BOOL)uploadSong:(NSString*)title forRadioId:(NSNumber*)radio_id album:(NSString*)album artist:(NSString *)artist songId:(NSNumber*)songId target:(id)target action:(SEL)selector progressDelegate:(id)progressDelegate;




- (BOOL)canUploadSong:(NSString*)title album:(NSString*)album artist:(NSString *)artist;

//- (BOOL)uploadSong:(SongUploading*)song forRadioId:(NSNumber*)radio_id target:(id)target action:(SEL)selector progressDelegate:(id)progressDelegate;

- (BOOL)uploadSong:(SongUploading*)song forRadioId:(NSNumber*)radio_id completionBlock:(YaRequestCompletionBlock)completionBlock progressBlock:(YaRequestProgressBlock)progressBlock;


- (BOOL)canUploadSong:(Song*)song;


- (void)cancelSongUpload;


@end
