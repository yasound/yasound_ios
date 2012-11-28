//
//  ProgrammingAlbumViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProgrammingCatalogViewController.h"
#import "SongCatalog.h"
#import "YasoundRadio.h"


@interface ProgrammingAlbumViewController : ProgrammingCatalogViewController <UIActionSheetDelegate>

@property (nonatomic, retain) YasoundRadio* radio;
@property (nonatomic, assign) SongCatalog* catalog;

- (id)initWithStyle:(UITableViewStyle)style  usingCatalog:(SongCatalog*)catalog forRadio:(YasoundRadio*)radio;



@end
