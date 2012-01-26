//
//  StyleSelectorViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyTracker.h"

@protocol StyleSelectorDelegate <NSObject>
@required

- (void)didSelectStyle:(NSString*)style;
- (void)cancelSelectStyle;

@end


@interface StyleSelectorViewController : TrackedUIViewController<UIPickerViewDataSource, UIPickerViewDelegate>
{
  
}

@property (nonatomic, retain) NSArray* styles;
@property (retain) id<StyleSelectorDelegate> delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil target:(id)target;
- (IBAction)onDoneClicked:(id)sender;

@end
