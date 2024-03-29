//
//  MyRadiosViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopBar.h"
#import "YaRadio.h"

@interface MyRadiosViewController : YaViewController<TopBarDelegate, UITableViewDelegate>
{
    UIActionSheet* _sheetTools;
    NSInteger _tokens;
    BOOL _firstTime;
}

@property (nonatomic, retain) UINib* cellLoader;

@property (nonatomic, retain) NSArray* radios;
@property (nonatomic, retain) NSMutableDictionary* editing;

@property (nonatomic, retain) IBOutlet UITableView* tableview;

@end
