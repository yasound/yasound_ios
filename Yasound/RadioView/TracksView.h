//
//  TracksView.h
//  testDragCells
//
//  Created by LOIC BERTHELOT on 21/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TracksView : UITableView <UITableViewDelegate, UITableViewDataSource>
{
    NSIndexPath* _selectedIndexPath;
    NSMutableArray* _data;
}


@end
