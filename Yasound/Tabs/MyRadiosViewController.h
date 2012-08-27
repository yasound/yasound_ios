//
//  MyRadiosViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBar.h"
#import "TopBar.h"
#import "Radio.h"

@interface MyRadiosViewController : UIViewController<TopBarDelegate, TabBarDelegate, UITableViewDelegate>
{
    UIActionSheet* _sheetTools;
}

@property (nonatomic, retain) Radio* radioToBroadcast;

@property (nonatomic, retain) UINib* cellLoader;

@property (nonatomic, retain) NSArray* radios;
@property (nonatomic, retain) NSMutableDictionary* editing;

@property (nonatomic, retain) IBOutlet UITableView* tableview;
@property (nonatomic, retain) IBOutlet TabBar* tabBar;

@end
