//
//  UIScrollViewTestAppDelegate.h
//  UIScrollViewTest
//
//  Created by Sébastien Métrot on 10/24/11.
//  Copyright 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"


//@interface YasoundAppDelegate : NSObject <UIApplicationDelegate, MainViewDelegate>
@interface YasoundAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain)  IBOutlet UIWindow *window;
@property (nonatomic, retain)  UINavigationController *navigationController;
@property (nonatomic, retain) MainViewController* mainViewController;

@end
