//
//  SongUploader.h
//  Yasound
//
//  Created by Jérôme BLONDON on 08/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongUploader : NSObject
+ (SongUploader*)main;

- (BOOL)uploadSong:(NSString*)title album:(NSString*)album artist:(NSString *)artist;

@end
