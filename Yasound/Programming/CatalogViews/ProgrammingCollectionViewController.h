//
//  ProgrammingCollectionViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "YaViewController.h"
#import "SongCatalog.h"
#import "Radio.h"
#import "ProgrammingArtistViewController.h"


@interface ProgrammingCollectionViewController : UITableViewController <UIActionSheetDelegate>

@property (nonatomic, retain) Radio* radio;
@property (nonatomic, assign) SongCatalog* catalog;
@property (nonatomic, retain) NSArray* artists;
@property (nonatomic, retain) ProgrammingArtistViewController* artistVC;


- (id)initWithStyle:(UITableViewStyle)style  usingCatalog:(SongCatalog*)catalog withArtists:(NSArray*)artists forRadio:(Radio*)radio;



@end
