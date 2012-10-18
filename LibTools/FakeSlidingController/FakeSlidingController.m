//
//  FakeSlidingController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "FakeSlidingController.h"
#import "RootViewController.h"
#import "YasoundAppDelegate.h"

@implementation FakeSlidingController

@synthesize panGesture;
@synthesize menuHidden;


- (id)init
{
    if (self = [super init])
    {
        self.menuHidden = YES;
    }
    
    return self;
}

- (UIViewController*)underLeftViewController
{
    NSInteger nb = self.viewControllers.count;
    if (nb < 1)
        return nil;
    UIViewController* view = [self.viewControllers objectAtIndex:(nb -1)];
    return view;
}


- (void)setUnderLeftViewController:(UIViewController*)viewController
{
}

- (void)setUnderLeftWidthLayout:(ECViewWidthLayout)layout
{

}

- (void)setTopViewController:(UIViewController*)viewCont
{
    [self pushViewController:viewCont animated:YES];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{

}


- (void)didMoveToParentViewController:(UIViewController *)parent
{

}

- (void)resetTopView
{
    self.menuHidden = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_SELECTION object:nil];
}

- (void)setAnchorRightRevealAmount:(CGFloat)amount
{

}

- (BOOL)underLeftShowing
{
    return (self.menuHidden == NO);
}

- (void)anchorTopViewTo:(ECSide)side
{
    self.menuHidden = NO;
    
    UIViewController* view = APPDELEGATE.menuViewController;
    [self popToViewController:view animated:YES];
}


@end

