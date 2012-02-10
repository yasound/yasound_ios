//
//  SongsViewController.h
//  Yasound
//
//  Created by Jérôme BLONDON on 09/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "TestflightViewController.h"
#import "Playlist.h"
#import "Song.h"

@interface SongsViewController : TestflightViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    NSInteger _playlistId;
    IBOutlet UITableView* _tableView;  
    
    NSMutableArray* _matchedSongs; // Array of Song*
    NSMutableArray* _unmatchedSongs; // Array of Song*
    NSMutableArray* _needSyncSongs; // Array of Song*
    NSMutableArray* _protectedSongs; // Array o Song*
    
    Song* _selectedSong;
}
- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil playlistId:(NSInteger)playlistId;
-(IBAction)onBack:(id)sender;

- (void)receiveSongs:(NSArray*)songs withInfo:(NSDictionary*)info;
- (void)resetArrays;
- (void)refreshView;
@end
