//
//  DB.h
//  astrosurf
//
//  Created by LOIC BERTHELOT on 13/04/12.
//  Copyright (c) 2012 loïc berthelot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"


@interface DB : NSObject

@property (nonatomic, retain) FMDatabase* db;
@property (nonatomic, retain) NSString* cacheDirectory;

+ (DB*)main;

// return local filepath for cached image from the original url
- (NSString*)getImage:(NSString*)url;

// store a local copy of image with its original url, and return the local filepath
- (NSString*)setImage:(NSData*)imageData forUrl:(NSString*)url;

// register the use of this image with the given post
- (void)registerImage:(NSString*)url forPost:(NSString*)postKey fromAuthor:(NSString*)author;
- (BOOL)isImageRegistered:(NSString*)url forPost:(NSString*)postKey fromAuthor:(NSString*)author;

// return array of registered images for the given postKey
- (NSArray*)registeredImages:(NSString*)postKey;
- (NSArray*)registeredPostKeys:(NSString*)url;
- (NSArray*)registeredImagesFromAuthor:(NSString*)author;


- (void)setMessageForPostKey:(NSString*)postKey replyNum:(NSString*)replyNum author:(NSString*)author emoticon:(NSString*)emoticon pubDate:(NSDate*)pubDate text:(NSString*)text subject:(NSString*)subject  forumKey:(NSString*)forumKey topic:(NSString*)topic;
- (NSDictionary*)messageForPostKey:(NSString*)postKey andReplyNum:(NSString*)replyNum;


//- (void)setUser:(NSString*)name withProfileUrl:(NSString*)profileUrl;
//- (NSString*)getProfileUrlForUser:(NSString*)name;



- (void)clearForPost:(NSString*)postKey;

- (void)clearCache;

@end
