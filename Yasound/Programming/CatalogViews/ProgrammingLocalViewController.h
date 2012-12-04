//
//  ProgrammingLocalViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YaRadio.h"
#import "ProgrammingCatalogViewController.h"
#import "ProgrammingViewController.h"
#import "ProgrammingCollectionViewController.h"

@interface ProgrammingLocalViewController : ProgrammingCatalogViewController

@property (nonatomic, retain) YaRadio* radio;
@property (nonatomic) NSInteger selectedSegmentIndex;
@property (nonatomic, retain) NSString* title;

@property (nonatomic, retain) ProgrammingCollectionViewController* collectionVC;


- (id)initWithStyle:(UITableViewStyle)style forRadio:(YaRadio*)radio withSegmentIndex:(NSInteger)segmentIndex;

- (void)setSegment:(NSInteger)index;






@end
