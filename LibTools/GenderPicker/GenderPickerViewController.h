//
//  GenderPickerViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestflightViewController.h"

@protocol GenderPickerDelegate <NSObject>
@required

- (void)genderDidSelect:(NSString*)gender;
- (UINavigationController *)genderNavController;          // Return the navigation controller

@end


@interface GenderPickerViewController : TestflightViewController<UIPickerViewDataSource, UIPickerViewDelegate>
{
  IBOutlet UIPickerView* _pickerView;
  NSString* _startItem;
}

@property (nonatomic, retain) NSArray* items;
@property (retain) id<GenderPickerDelegate> delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil currentItem:(NSString*)currentItem target:(id)target;
- (IBAction)onDoneClicked:(id)sender;
- (IBAction)onCancelClicked:(id)sender;

@end
