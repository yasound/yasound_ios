//
//  ConstantCellTableViewController.h
//  testConstantCellTableView
//
//  Created by LOIC BERTHELOT on 22/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConstantCellTableViewController : UIViewController
{
  IBOutlet UITableView* _tableView;
  UITableViewCell* _cellNowPlaying;
  NSIndexPath* _indexPathNowPlaying;
  BOOL _rectNowPlayingIsSet;
  CGRect _rectNowPlaying;
  
  UIView* _viewNowPlaying;
  BOOL _viewNowPlayingAnchored;
  CGFloat _viewNowPlayingPosY;
  
}

@end
