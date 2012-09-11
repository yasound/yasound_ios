//
//  GiftsViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPPopoverController.h"


@interface GiftsViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UIImageView* iconHd;
@property (nonatomic, retain) IBOutlet UILabel* labelHd;
@property (nonatomic, retain) IBOutlet UISwitch* switchHd;
@property (nonatomic, retain) IBOutlet UILabel* promoLabel;
@property (nonatomic, retain) IBOutlet UITextField* promoText;

@property(nonatomic, retain) FPPopoverController* popover;

@property(nonatomic, retain) NSArray* gifts;

- (IBAction)hdSwitchChanged:(id)sender;
- (IBAction)promoCodeEntered:(id)sender;

@end
