//
//  RadioSelectionViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QualitySwitchLabel.h"
#import "TestflightViewController.h"


@interface RadioSelectionViewController : TestflightViewController
{
    IBOutlet QualitySwitchLabel* _qualitySwitchLabel;
    IBOutlet UILabel* _topBarTitle;
    IBOutlet UILabel* _categoryTitle;
    IBOutlet UIBarButtonItem* _nowPlayingButton;
    
    IBOutlet UITableView* _tableView;  
    
    NSString* _currentStyle;
    
    NSMutableArray* _radios;
}

@property (nonatomic, retain) NSURL* url;

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withUrl:(NSURL*)url andTitle:(NSString*)title;

- (IBAction)onStyleSelectorClicked:(id)sender;
- (IBAction)onNowPlayingClicked:(id)sender;

@end
