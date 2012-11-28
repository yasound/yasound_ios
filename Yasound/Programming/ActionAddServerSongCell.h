//
//  ActionAddServerSongCell.h
//  Yasound
//
//  Created by mat on 19/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YasoundSong.h"
#import "YasoundRadio.h"
#import "WebImageView.h"

@interface ActionAddServerSongCell : UITableViewCell

@property (nonatomic, assign) YasoundSong* song;
@property (nonatomic, assign) YasoundRadio* radio;

@property (nonatomic, retain) WebImageView* image;
@property (nonatomic, retain) UILabel* label;
@property (nonatomic, retain) UILabel* detailedLabel;
@property (nonatomic, retain) UIButton* button;
@property (nonatomic, retain) UIActivityIndicatorView* activityView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier song:(YasoundSong*)s forRadio:(YasoundRadio*)r;

- (void)update:(YasoundSong*)song;

@end
