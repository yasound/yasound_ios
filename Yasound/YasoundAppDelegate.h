//
//  UIScrollViewTestAppDelegate.h
//  UIScrollViewTest
//
//  Created by Sébastien Métrot on 10/24/11.
//  Copyright 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AudioStreamer;
@class RadioCreator;
@class RadioViewController;

@interface YasoundAppDelegate : NSObject <UIApplicationDelegate>
{
  UIScrollView* mpScrollView;
  RadioCreator* mpCreator;
  AudioStreamer* mpStreamer;
  RadioViewController* mpRadio;
  
  BOOL radioCreated;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

- (void) createRadioList;
- (IBAction)onCreateRadio:(id)sender;
- (IBAction)onAccessRadio:(id)sender;
- (IBAction)onQuitRadio:(id)sender;

@end
