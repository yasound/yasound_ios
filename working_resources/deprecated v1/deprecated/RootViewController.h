//
//  RootViewController.h
//  Yasound
//
//  Created by Loic Berthelot on 11/7/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AudioStreamer;
@class RadioCreatorViewController;
@class RadioViewController;

@interface RootViewController : UIViewController
{
  UIScrollView* mpScrollView;
  RadioCreatorViewController* mpCreator;
  AudioStreamer* mpStreamer;
  RadioViewController* mpRadio;
  
  BOOL radioCreated;
}

- (void) createRadioList;
- (IBAction)onCreateRadio:(id)sender;
- (IBAction)onAccessRadio:(id)sender;
- (IBAction)onQuitRadio:(id)sender;

@end