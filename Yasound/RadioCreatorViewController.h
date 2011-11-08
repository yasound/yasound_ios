//
//  RadioCreatorViewController.h
//  Yasound
//
//  Created by Sébastien Métrot on 11/1/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

// delegate protocol to let the parent manage this view controller
@protocol RadioCreatorDelegate <NSObject>
@required
- (void)radioDidCreate:(UIViewController*)modalViewController;
@end


@interface RadioCreatorViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
  IBOutlet UITextField* radioName;
  IBOutlet UITableView* playlists;
  IBOutlet UIButton* createButton;
  
  NSArray* lists;
  NSMutableSet* selectedLists;
  
  id<RadioCreatorDelegate> _delegate;
}

@property id<RadioCreatorDelegate> delegate;


@end
