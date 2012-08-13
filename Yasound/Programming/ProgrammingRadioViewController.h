//
//  ProgrammingRadioViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "TestflightViewController.h"
#import "Radio.h"
#import "ProgrammingViewController.h"


@interface ProgrammingRadioViewController : UITableViewController <UIActionSheetDelegate>
{
//    IBOutlet UIBarButtonItem* _synchroBtn;
    
//    IBOutlet UILabel* _titleLabel;
//    IBOutlet UILabel* _subtitleLabel;
//    IBOutlet UIToolbar* _toolbar;
//    IBOutlet UISegmentedControl* _segment;
}

@property (nonatomic, retain) Radio* radio;
@property (nonatomic, retain) NSMutableDictionary* sortedSongs;
@property (nonatomic, retain) NSMutableDictionary* sortedArtists;

@property (nonatomic) NSInteger selectedSegmentIndex;

- (id)initWithStyle:(UITableViewStyle)style forRadio:(Radio*)radio;


@end
