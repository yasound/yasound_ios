//
//  UIScrollViewTestAppDelegate.h
//  UIScrollViewTest
//
//  Created by Sébastien Métrot on 10/24/11.
//  Copyright 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AudioStreamer;

@interface UIScrollViewTestAppDelegate : NSObject <UIApplicationDelegate>
{
  UIScrollView* mpScrollView;
  UIScrollView* mpInnerScrollView;
  AudioStreamer* mpStreamer;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
