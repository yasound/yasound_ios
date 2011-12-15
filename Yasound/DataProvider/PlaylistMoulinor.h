//
//  PlaylistMoulinor.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PlaylistMoulinor : NSObject

#define PM_ACTION_ADD @"ADD"
#define PM_ACTION_DELETE @"DEL"

#define PM_TAG_PLAYLIST @"LST"
#define PM_TAG_ARTIST @"ART"
#define PM_TAG_ALBUM @"ALB"
#define PM_TAG_SONG @"SNG"


+ (PlaylistMoulinor*)main;

- (NSData*)dataWithPlaylists:(NSArray*)mediaPlaylists;

@end
