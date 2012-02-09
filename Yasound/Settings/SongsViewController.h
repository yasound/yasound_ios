//
//  SongsViewController.h
//  Yasound
//
//  Created by Jérôme BLONDON on 09/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "TestflightViewController.h"
#import "Playlist.h"

@interface SongsViewController : TestflightViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSInteger _playlistId;
    IBOutlet UITableView* _tableView;  
    
    NSMutableArray* _matchedSongs; // Array of Song*
    NSMutableArray* _unmatchedSongs; // Array of Song*
}
- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil playlistId:(NSInteger)playlistId;
-(IBAction)onBack:(id)sender;

- (void)receiveSongs:(NSArray*)songs withInfo:(NSDictionary*)info;

@end
