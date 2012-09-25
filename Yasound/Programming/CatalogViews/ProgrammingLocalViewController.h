//
//  ProgrammingLocalViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Radio.h"
#import "ProgrammingCatalogViewController.h"
#import "ProgrammingViewController.h"
#import "ProgrammingCollectionViewController.h"
//#import "ProgrammingGenreViewController.h"

@interface ProgrammingLocalViewController : ProgrammingCatalogViewController

@property (nonatomic, retain) Radio* radio;
//@property (nonatomic, retain) NSMutableDictionary* sortedArtists;
//@property (nonatomic, retain) NSMutableDictionary* sortedSongs;
@property (nonatomic) NSInteger selectedSegmentIndex;

@property (nonatomic, retain) ProgrammingCollectionViewController* collectionVC;
//@property (nonatomic, retain) ProgrammingGenreViewController* genreVC;


- (id)initWithStyle:(UITableViewStyle)style forRadio:(Radio*)radio withSegmentIndex:(NSInteger)segmentIndex;

- (void)setSegment:(NSInteger)index;






@end
