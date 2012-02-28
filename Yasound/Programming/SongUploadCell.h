//
//  SongUploadCell.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongUploadManager.h"


@interface SongUploadCell : UITableViewCell

@property (nonatomic, assign) SongUploadItem* item;
@property (nonatomic, retain) UILabel* label;
@property (nonatomic, retain) UILabel* labelStatus;
@property (nonatomic, retain) UIProgressView* progressView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier mediaItem:(SongUploadItem*)item;

- (void)update:(SongUploadItem*)mediaItem;

@end
