//
//  RadioCreatorViewController.h
//  Yasound
//
//  Created by Sébastien Métrot on 11/1/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RadioCreatorViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
  IBOutlet UITextField* radioName;
  IBOutlet UITableView* playlists;
  IBOutlet UIButton* createButton;
  
  NSArray* lists;
  NSMutableSet* selectedLists;
}

- (IBAction)CreateRadio:(id)sender;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;

@end
