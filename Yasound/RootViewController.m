//
//  RootViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 04/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "RootViewController.h"
#import "HomeViewController.h"
#import "RadioTabBarController.h"
#import "RadioViewController.h"
#import "YasoundSessionManager.h"



@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        _firstTime = YES;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPushRadio:) name:@"NOTIF_PushRadio" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoginScreen:) name:@"NOTIF_LoginScreen" object:nil];
    
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_firstTime)
    {
        _firstTime = NO;
     
        [self loginProcess];
    }

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)loginProcess
{
    if ([YasoundSessionManager main].registered)
    {
        [[YasoundSessionManager main] loginWithTarget:self action:@selector(loginReturned:)];
    }
    else
    {
        HomeViewController* view = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
        [self.navigationController pushViewController:view animated:NO];
        [view release];
    }
}

- (void)loginReturned:(NSNumber*)successful
{
    BOOL res = [successful boolValue];
    if (res)
    {
        [self launchRadio];
    }
    else
    {
        [[YasoundSessionManager main] logoutWithTarget:self action:@selector(logoutReturned)];
    }
}

- (void)logoutReturned
{

}



- (void)onPushRadio:(NSNotification *)notification
{
    // go back to root, removing all viewcontroller
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self launchRadio];
}

- (void)onLoginScreen:(NSNotification *)notification
{
    [self.navigationController popToRootViewControllerAnimated:NO];

    HomeViewController* view = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:NO];
    [view release];
}



- (void)launchRadio
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"automaticLaunch"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // add tabs
    RadioTabBarController* tabBarController = [[RadioTabBarController alloc] init];
    [self.navigationController pushViewController:tabBarController animated:NO];    
    [tabBarController release];
}

@end
