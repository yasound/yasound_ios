//
//  MenuViewController.m
//  testSliding
//
//  Created by neywen on 21/08/12.
//  Copyright (c) 2012 neywen. All rights reserved.
//

#import "MenuViewController.h"
#import "AppDelegate.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [APPDELEGATE.slidingController setAnchorRightRevealAmount:264.0f];
    APPDELEGATE.slidingController.underLeftWidthLayout = ECFullWidth;
    
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 320, 30)];
    label.text = @"MenuViewController";
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
