//
//  PlaylistMoulinor.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PlaylistMoulinor : NSObject
{
    UIViewController* _emailController;
}

#define PM_ACTION_ADD @"ADD"
#define PM_ACTION_DELETE @"DEL"

#define PM_TAG_PLAYLIST @"LST"
#define PM_TAG_ARTIST @"ART"
#define PM_TAG_ALBUM @"ALB"
#define PM_TAG_SONG @"SNG"

#define PM_FIELD_UNKNOWN @""


+ (PlaylistMoulinor*)main;

- (NSData*)dataWithPlaylists:(NSArray*)mediaPlaylists binary:(BOOL)binary compressed:(BOOL)compressed;

- (void)emailData:(NSData*)data to:(NSString*)email mimetype:(NSString*)mimetype filename:(NSString*)filename controller:(UIViewController*)controller;

@end
