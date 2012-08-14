//
//  ProgrammingLocalViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WheelSelector.h"
#import "Radio.h"
#import "ProgrammingViewController.h"
#import "ProgrammingArtistViewController.h"

@interface ProgrammingLocalViewController : UITableViewController
{
//    IBOutlet UIBarButtonItem* _backBtn;
//    IBOutlet UILabel* _titleLabel;
//    IBOutlet UILabel* _subtitleLabel;
//    IBOutlet UISegmentedControl* _segment;
//    IBOutlet UITableView* _tableView;
//    IBOutlet UIView* _searchView;
//    IBOutlet UIToolbar* _navBar;
//    IBOutlet UIToolbar* _toolbar;
    
//    IBOutlet UIView* _itunesConnectView;
//    IBOutlet UILabel* _itunesConnectLabel;
    
//    IBOutlet UISearchBar* _searchBar;
//    NSInteger _selectedIndex;
//    IBOutlet UISearchDisplayController* _searchController;
    
}

@property (nonatomic, retain) Radio* radio;
//@property (nonatomic, retain) WheelSelector* wheelSelector;

//@property (nonatomic, retain) NSMutableArray* searchedSongs;
//@property (nonatomic, retain) NSString* subtitle;
@property (nonatomic, retain) NSMutableDictionary* sortedArtists;
@property (nonatomic, retain) NSMutableDictionary* sortedSongs;
@property (nonatomic) NSInteger selectedSegmentIndex;
//@property (nonatomic, retain) NSMutableArray* localSongs;
//@property (nonatomic, retain) NSArray* remoteSongs;
//
//@property (nonatomic, assign) NSDictionary* matchedSongs;

@property (nonatomic, retain) ProgrammingArtistViewController* artistVC;


- (id)initWithStyle:(UITableViewStyle)style forRadio:(Radio*)radio;

- (void)setSegment:(NSInteger)index;






@end
