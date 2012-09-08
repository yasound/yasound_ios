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

@property (nonatomic, retain) Radio* radio;
//@property (nonatomic, retain) NSMutableDictionary* sortedArtists;
//@property (nonatomic, retain) NSMutableDictionary* sortedSongs;
@property (nonatomic) NSInteger selectedSegmentIndex;

@property (nonatomic, retain) ProgrammingArtistViewController* artistVC;


- (id)initWithStyle:(UITableViewStyle)style forRadio:(Radio*)radio;

- (void)setSegment:(NSInteger)index;






@end
