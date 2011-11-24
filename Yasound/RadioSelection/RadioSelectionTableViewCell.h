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

@end
