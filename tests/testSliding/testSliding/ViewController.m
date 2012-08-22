//
//  ViewController.m
//  testSliding
//
//  Created by neywen on 21/08/12.
//  Copyright (c) 2012 neywen. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 320, 30)];
    label.text = @"ViewController";
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
    
    [self.view addGestureRecognizer:APPDELEGATE.slidingController.panGesture];

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


- (IBAction)onClick:(id)sender
{
    if ([APPDELEGATE.slidingController underLeftShowing])
        [APPDELEGATE.slidingController resetTopView];
    else
        [  APPDELEGATE.slidingController anchorTopViewTo:ECRight];
    
}


@end
