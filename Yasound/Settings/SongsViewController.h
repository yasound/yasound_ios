//
//  SongsViewController.h
//  Yasound
//
//  Created by Jérôme BLONDON on 09/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "YaViewController.h"
#import "Playlist.h"
#import "Song.h"
#import "MBProgressHUD.h"
#import "Radio.h"

@interface SongsViewController : YaViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    NSInteger _playlistId;
    IBOutlet UITableView* _tableView;  
    
    NSArray* _songs; // Array of Song*

    Song* _selectedSong;
    MBProgressHUD* _hud;
}

@property (nonatomic, retain) Radio* radio;

- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil playlistId:(NSInteger)playlistId forRadio:radio;
-(IBAction)onBack:(id)sender;

- (void)receiveSongs:(NSArray*)songs withInfo:(NSDictionary*)info;
- (void)resetArrays;
- (void)refreshView;
@end
