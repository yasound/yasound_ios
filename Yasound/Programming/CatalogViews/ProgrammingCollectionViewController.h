//
//  ProgrammingCollectionViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProgrammingCatalogViewController.h"
#import "SongCatalog.h"
#import "YaRadio.h"
#import "ProgrammingArtistViewController.h"


@interface ProgrammingCollectionViewController : ProgrammingCatalogViewController <UIActionSheetDelegate>

@property (nonatomic, retain) YaRadio* radio;
@property (nonatomic, assign) SongCatalog* catalog;
@property (nonatomic, retain) NSArray* artists;
@property (nonatomic, retain) ProgrammingArtistViewController* artistVC;


- (id)initWithStyle:(UITableViewStyle)style  usingCatalog:(SongCatalog*)catalog withArtists:(NSArray*)artists forRadio:(YaRadio*)radio;



@end
