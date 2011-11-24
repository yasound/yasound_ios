//
//  RadioSelectionTableViewCell.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RadioSelectionTableViewCell : UITableViewCell
{
}


@property (nonatomic, retain) UILabel* radioTitle;
@property (nonatomic, retain) UILabel* radioSubtitle1;
@property (nonatomic, retain) UILabel* radioSubtitle2;
@property (nonatomic, retain) UILabel* radioLikes;
@property (nonatomic, retain) UILabel* radioListeners;
@property (nonatomic, retain) UIImageView* radioAvatar;
@property (nonatomic, retain) UIImageView* radioAvatarMask;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier rowIndex:(NSInteger)rowIndex;

@end
