//
//  FakeSlidingController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"

@interface FakeSlidingController : UINavigationController

@property (nonatomic, retain) UIPanGestureRecognizer* panGesture;

@property (nonatomic) BOOL menuHidden;


- (UIViewController*)underLeftViewController;
- (void)setUnderLeftViewController:(UIViewController*)viewController;
- (void)setUnderLeftWidthLayout:(ECViewWidthLayout)layout;
- (void)setTopViewController:(UINavigationController*)navCont;
- (void)willMoveToParentViewController:(UIViewController *)parent;
- (void)didMoveToParentViewController:(UIViewController *)parent;
- (void)setAnchorRightRevealAmount:(CGFloat)amount;
- (void)anchorTopViewTo:(ECSide)side;
- (BOOL)underLeftShowing;
- (void)resetTopView;

@end


