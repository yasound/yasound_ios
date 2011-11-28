//
//  ConstantCellTableViewController.h
//  testConstantCellTableView
//
//  Created by LOIC BERTHELOT on 22/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum
{
  CCPTop,
  CCPBottom,
  CCPPositionNone
} ConstantCellPosition;

typedef enum 
{
  CCPUp,
  CCPDown,
  CCPDirectionNone
} ConstantCellDirection;


@interface ConstantCellTableViewController : UIViewController
{
  IBOutlet UITableView* _tableView;
  UITableViewCell* _cellNowPlaying;
  NSIndexPath* _indexPathNowPlaying;
  BOOL _rectNowPlayingIsSet;
  CGRect _rectNowPlaying;
  
  UIView* _viewNowPlaying;
  CGFloat _viewNowPlayingPosY;
  
  ConstantCellPosition _viewNowPlayingPosition;
  
  CGFloat _scrollviewLastPosY;
}

@end

