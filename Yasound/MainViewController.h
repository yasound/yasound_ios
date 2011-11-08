//
//  MainViewController.h
//  Yasound
//
//  Created by Loic Berthelot on 11/7/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioCreatorViewController.h"

@interface MainViewController : UIViewController<RadioCreatorDelegate>
{
  UIView* _headerView;
  UIButton* _myRadioButton;
  BOOL _radioCreated;
}

@end