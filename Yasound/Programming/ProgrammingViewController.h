//
//  ProgrammingViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "YaViewController.h"
#import "WheelSelectorRadios.h"
#import "YasoundRadio.h"
#import "TopBarBackAndTitle.h"

#define RADIOSEGMENT_INDEX_TITLES 0
#define RADIOSEGMENT_INDEX_ARTISTS 1

#define LOCALSEGMENT_INDEX_PLAYLISTS 0
#define LOCALSEGMENT_INDEX_GENRES 1
#define LOCALSEGMENT_INDEX_TITLES 2


#define PROGRAMMING_WHEEL_NB_ITEMS 4
#define PROGRAMMING_WHEEL_ITEM_YASOUND_SERVER 0
#define PROGRAMMING_WHEEL_ITEM_LOCAL 1
#define PROGRAMMING_WHEEL_ITEM_RADIO 2
#define PROGRAMMING_WHEEL_ITEM_UPLOADS 3

@interface ProgrammingViewController : YaViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, WheelSelectorDelegate, TopBarBackAndTitleDelegate>
{
    IBOutlet UIView* _containerRadioSegment;
    IBOutlet UIView* _containerLocalSegment;
    IBOutlet UIView* _containerEmptySegment;
    IBOutlet UISegmentedControl* _radioSegment;
    IBOutlet UISegmentedControl* _localSegment;
}

@property (nonatomic, retain) IBOutlet UIView* container;
@property (nonatomic, retain) IBOutlet WheelSelectorRadios* wheelSelector;
@property (nonatomic, retain) IBOutlet TopBarBackAndTitle* topbar;

@property (nonatomic, retain) IBOutlet UILabel* topbarTitle;
@property (nonatomic, retain) IBOutlet UILabel* topbarSubtitle;

@property (nonatomic, retain) YasoundRadio* radio;
@property (nonatomic, retain) UIViewController* viewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forRadio:(YasoundRadio*)radio;


@end
