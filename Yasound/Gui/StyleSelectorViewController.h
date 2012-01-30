//
//  StyleSelectorViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestflightViewController.h"

@protocol StyleSelectorDelegate <NSObject>
@required

- (void)didSelectStyle:(NSString*)style;
- (void)closeSelectStyleController;

@end


@interface StyleSelectorViewController : TestflightViewController<UIPickerViewDataSource, UIPickerViewDelegate>
{
  IBOutlet UIPickerView* stylePickerView;
  NSString* _startStyle;
}

@property (nonatomic, retain) NSArray* styles;
@property (retain) id<StyleSelectorDelegate> delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil currentStyle:(NSString*)currentStyle target:(id)target;
- (IBAction)onDoneClicked:(id)sender;
- (IBAction)onCancelClicked:(id)sender;

@end
