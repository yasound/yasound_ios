//
//  TestflightViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 26/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "TestflightViewController.h"
#import "TestFlight.h"

@implementation TestflightViewController

@synthesize didLoadCheckpoint = _didLoadCheckpoint;
@synthesize didAppearCheckpoint = _didAppearCheckpoint;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.didLoadCheckpoint =  [NSString stringWithFormat:@"%@ viewDidLoad", [self class]];
        self.didAppearCheckpoint =  [NSString stringWithFormat:@"%@ viewDidAppear", [self class]];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#ifdef TESTFLIGHT_SDK
    [TestFlight passCheckpoint:self.didLoadCheckpoint];
#endif
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
#ifdef TESTFLIGHT_SDK
    [TestFlight passCheckpoint:self.didAppearCheckpoint];
#endif
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
