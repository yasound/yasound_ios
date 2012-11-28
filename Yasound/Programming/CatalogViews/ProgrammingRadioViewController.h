//
//  ProgrammingRadioViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProgrammingCatalogViewController.h"
#import "YasoundRadio.h"
#import "ProgrammingViewController.h"
#import "ProgrammingArtistViewController.h"
#import "ObjectButton.h"

@interface ProgrammingRadioViewController : ProgrammingCatalogViewController <UIActionSheetDelegate>

@property (nonatomic, retain) YasoundRadio* radio;
@property (nonatomic, retain) NSMutableDictionary* songToIndexPath;
@property (nonatomic, retain) NSString* title;


@property (nonatomic) NSInteger selectedSegmentIndex;

@property (nonatomic, retain) ProgrammingArtistViewController* artistVC;

- (id)initWithStyle:(UITableViewStyle)style forRadio:(YasoundRadio*)radio;
- (void)setSegment:(NSInteger)index;
- (BOOL)onBackClicked;

@end
