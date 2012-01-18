//
//  RadioSelectionTableViewCell.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebImageView.h"
#import "YasoundDataProvider.h"

@interface UserTableViewCell : UITableViewCell
{
  UIImage* _maskBackup;
  UIImage* _maskSelected;
  UIImage* _bkgBackup;
  UIImage* _bkgSelected;

}

@property (nonatomic, retain) User* user;
@property (nonatomic, retain) UILabel* userName;
@property (nonatomic, retain) UILabel* radioStatus;
//@property (nonatomic, retain) UILabel* radioSubtitle1;
//@property (nonatomic, retain) UILabel* radioSubtitle2;
//@property (nonatomic, retain) UILabel* radioLikes;
//@property (nonatomic, retain) UILabel* radioListeners;
@property (nonatomic, retain) UIImageView* cellBackground;
@property (nonatomic, retain) WebImageView* userAvatar;
@property (nonatomic, retain) UIImageView* userAvatarMask;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier rowIndex:(NSInteger)rowIndex user:(User*)u;


@end
