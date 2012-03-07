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


@interface SongUploader : NSObject 
{
  NSString* _tempSongFile;
    ASIFormDataRequest* _request;
  id _target;
  SEL _selector;
}


+ (SongUploader*)main;



- (BOOL)uploadSong:(NSString*)title album:(NSString*)album artist:(NSString *)artist songId:(NSNumber*)songId target:(id)target action:(SEL)selector progressDelegate:(id)progressDelegate;
- (BOOL)canUploadSong:(NSString*)title album:(NSString*)album artist:(NSString *)artist;

- (BOOL)uploadSong:(Song*)song target:(id)target action:(SEL)selector progressDelegate:(id)progressDelegate;
- (BOOL)canUploadSong:(Song*)song;


- (void)cancelSongUpload:(Song*)song;


@end
