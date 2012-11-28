//
//  ProgrammingLocalViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YasoundRadio.h"
#import "ProgrammingCatalogViewController.h"
#import "ProgrammingViewController.h"
#import "ProgrammingCollectionViewController.h"

@interface ProgrammingLocalViewController : ProgrammingCatalogViewController

@property (nonatomic, retain) YasoundRadio* radio;
@property (nonatomic) NSInteger selectedSegmentIndex;
@property (nonatomic, retain) NSString* title;

@property (nonatomic, retain) ProgrammingCollectionViewController* collectionVC;


- (id)initWithStyle:(UITableViewStyle)style forRadio:(YasoundRadio*)radio withSegmentIndex:(NSInteger)segmentIndex;

- (void)setSegment:(NSInteger)index;






@end
