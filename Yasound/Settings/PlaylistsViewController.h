//
//  PlaylistsViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 21/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyTracker.h"


@interface PlaylistsViewController : TrackedUIViewController
{
    IBOutlet UITableView* _tableView;  
    IBOutlet UITableViewCell* _cellHowto;
    IBOutlet UILabel* _cellHowtoLabel;

    IBOutlet UIView* _itunesConnectView;
    IBOutlet UILabel* _itunesConnectLabel;

    NSArray* _playlists;                   // NSArray of MPMediaPlaylist*
    NSMutableArray* _playlistsDesc;        // NSArray of NSDictionary {name, count}
    NSMutableArray* _selectedPlaylists;    // NSMutableArray of MPMediaPlaylist*
    
    UIBarButtonItem* _nextBtn;
}


@end
