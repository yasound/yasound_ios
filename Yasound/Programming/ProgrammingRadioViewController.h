//
//  ProgrammingRadioViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "YaViewController.h"
#import "Radio.h"
#import "ProgrammingViewController.h"
#import "ProgrammingArtistViewController.h"
#import "ObjectButton.h"

@interface ProgrammingRadioViewController : UITableViewController <UIActionSheetDelegate>
{
//    IBOutlet UIBarButtonItem* _synchroBtn;
    
//    IBOutlet UILabel* _titleLabel;
//    IBOutlet UILabel* _subtitleLabel;
//    IBOutlet UIToolbar* _toolbar;
//    IBOutlet UISegmentedControl* _segment;
    ObjectAlertView* _alertDeleteArtist;
}

@property (nonatomic, retain) Radio* radio;
@property (nonatomic, retain) NSMutableDictionary* sortedSongs;
@property (nonatomic, retain) NSMutableDictionary* sortedArtists;

@property (nonatomic, retain) NSMutableDictionary* artistToIndexPath;
@property (nonatomic, retain) NSString* deleteArtistNameFromClient;
@property (nonatomic) BOOL deleteRunning;
 

@property (nonatomic) NSInteger selectedSegmentIndex;

@property (nonatomic, retain) ProgrammingArtistViewController* artistVC;

- (id)initWithStyle:(UITableViewStyle)style forRadio:(Radio*)radio;
- (void)setSegment:(NSInteger)index;
- (BOOL)onBackClicked;

@end
