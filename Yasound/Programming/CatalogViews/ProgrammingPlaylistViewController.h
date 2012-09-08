//
//  ProgrammingAlbumViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "YaViewController.h"
#import "SongCatalog.h"
#import "Radio.h"


@interface ProgrammingAlbumViewController : UITableViewController <UIActionSheetDelegate>

@property (nonatomic, retain) Radio* radio;
@property (nonatomic, assign) SongCatalog* catalog;

- (id)initWithStyle:(UITableViewStyle)style  usingCatalog:(SongCatalog*)catalog forRadio:(Radio*)radio;



@end
