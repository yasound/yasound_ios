//
//  RadioCreator.h
//  Yasound
//
//  Created by Sébastien Métrot on 11/1/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RadioCreator : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
  IBOutlet UITextField* radioName;
  IBOutlet UITableView* playlists;
  IBOutlet UIButton* createButton;
  
  NSArray* lists;
  NSMutableSet* selectedLists;
}

- (IBAction)CreateRadio:(id)sender;

@end
