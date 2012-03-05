//
//  SongAddCell.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"


@interface SongAddCell : UITableViewCell

@property (nonatomic, assign) Song* song;

@property (nonatomic, retain) UILabel* label;
@property (nonatomic, retain) UILabel* detailedLabel;
@property (nonatomic, retain) UIButton* button;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier song:(Song*)song;

- (void)update:(Song*)song;

@end
