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
  IBOutlet UILabel* _radioTitle;
  IBOutlet UILabel* _radioSubtitle1;
  IBOutlet UILabel* _radioSubtitle2;
  IBOutlet UILabel* _radioLikes;
  IBOutlet UILabel* _radioListeners;
  IBOutlet UIImageView* _radioAvatar;
  IBOutlet UIImageView* _radioAvatarMask;
}


@property (nonatomic, retain)  UILabel* radioTitle;
@property (nonatomic, retain) IBOutlet UILabel* radioSubtitle1;
@property (nonatomic, retain) IBOutlet UILabel* radioSubtitle2;
@property (nonatomic, retain) IBOutlet UILabel* radioLikes;
@property (nonatomic, retain) IBOutlet UILabel* radioListeners;
@property (nonatomic, retain) IBOutlet UIImageView* radioAvatar;
@property (nonatomic, retain) IBOutlet UIImageView* radioAvatarMask;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier;

@end
