//
//  SongUploader.h
//  Yasound
//
//  Created by Jérôme BLONDON on 08/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongUploader : NSObject {
  NSString* _tempSongFile;
  id _target;
  SEL _selector;
}
+ (SongUploader*)main;

- (BOOL)uploadSong:(NSString*)title album:(NSString*)album artist:(NSString *)artist songId:(NSNumber*)songId target:(id)target action:(SEL)selector;

@end
