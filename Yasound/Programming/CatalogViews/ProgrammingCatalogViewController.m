//
//  ProgrammingCatalogViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProgrammingCatalogViewController.h"
#import "SongRadioCatalog.h"
#import "SongLocalCatalog.h"
#import "SongUploadManager.h"
#import "YasoundReachability.h"

@implementation ProgrammingCatalogViewController





#pragma mark - IBActions



- (void)onNotifSongAdded:(NSNotification*)notif
{
    
    [self.tableView reloadData];
}


- (void)onNotifSongRemoved:(NSNotification*)notif
{
//    UIViewController* sender = notif.object;
//    
//    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//
//    if (sender != self)
        [self.tableView reloadData];
}


- (void)onNotifSongUpdated:(NSNotification*)notif
{
//    UIViewController* sender = notif.object;
//    
//    if (sender != self)
        [self.tableView reloadData];
}



- (void)onNotificationUploadCanceled:(NSNotification*)notif
{
    [self.tableView reloadData];
}






// server's callback
- (void)onSongDeleted:(Song*)song info:(NSDictionary*)info
{
    DLog(@"onSongDeleted for Song %@", song.name);
    DLog(@"info %@", info);
    
    BOOL success = NO;
    NSNumber* nbsuccess = [info objectForKey:@"success"];
    if (nbsuccess != nil)
        success = [nbsuccess boolValue];
    
    DLog(@"success %d", success);
    
    UITableViewCell* cell = [info objectForKey:@"userData"];
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    
    //LBDEBUG
    assert(0);
    
    // refresh DataBase
    [[SongRadioCatalog main] updateSongRemovedFromProgramming:song];
    [[SongLocalCatalog main] updateSongRemovedFromProgramming:song];
    
    
    //     [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PROGAMMING_SONG_REMOVED object:self];
    
}





@end
