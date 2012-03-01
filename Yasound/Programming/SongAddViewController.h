//
//  SongAddViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongAddViewController : UIViewController
{
    IBOutlet UIBarButtonItem* _backBtn;
    IBOutlet UILabel* _titleLabel;
    IBOutlet UILabel* _subtitleLabel;
    IBOutlet UISegmentedControl* _segment;
    IBOutlet UITableView* _tableView;
    
    IBOutlet UIView* _itunesConnectView;
    IBOutlet UILabel* _itunesConnectLabel;
    
    
}


@property (nonatomic, retain) NSMutableArray* localSongs;
@property (nonatomic, retain) NSArray* remoteSongs;

@property (nonatomic, assign) NSSet* matchedSongs;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withMatchedSongs:(NSArray*)matchedSongs;

@end
