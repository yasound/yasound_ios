//
//  PlaylistMoulinor.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>



#define PM_TAG_PLAYLIST             @"LIST"
#define PM_TAG_ARTIST               @"ARTS"
#define PM_TAG_ALBUM                @"ALBM"
#define PM_TAG_SONG                 @"SONG"
#define PM_TAG_UUID                 @"UUID"
#define PM_TAG_REMOVE_PLAYLIST      @"REMV"
#define PM_TAG_REMOTE_PLAYLIST      @"RLST"

#define PM_FIELD_UNKNOWN @""



@interface PlaylistMoulinor : NSObject
{
    NSOperationQueue* _queue;
    
    BOOL _binary;
    BOOL _compressed;
    id _target;
    SEL _action;
    
    UIViewController* _emailController;
}

+ (PlaylistMoulinor*)main;

- (BOOL)buildDataWithPlaylists:(NSArray*)mediaPlaylists removedPlaylists:(NSArray*)removedPlaylists binary:(BOOL)binary compressed:(BOOL)compressed target:(id)target action:(SEL)action;

- (BOOL)buildDataWithSongs:(NSArray*)mediaSongs binary:(BOOL)binary compressed:(BOOL)compressed target:(id)target action:(SEL)action;

- (BOOL)buildArtistDataBinary:(BOOL)binary compressed:(BOOL)compressed target:(id)target action:(SEL)action userInfo:(id)info;

- (void)emailData:(NSData*)data to:(NSString*)email mimetype:(NSString*)mimetype filename:(NSString*)filename controller:(UIViewController*)controller;

@end
