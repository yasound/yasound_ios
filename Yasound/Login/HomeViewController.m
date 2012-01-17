//
//  HomeViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "HomeViewController.h"
#import "LoginViewController.h"
#import "SignupViewController.h"
#import "CreateMyRadio.h"
#import "MyYasoundViewController.h"
#import "RadioTabBarController.h"
#import "YasoundSessionManager.h"
#import "YasoundDataProvider.h"
#import "ActivityAlertView.h"
#import "RootViewController.h"



@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.title =  NSLocalizedString(@"HomeView_title", nil);        
    }
    return self;
}


- (void) dealloc
{
    [super dealloc];
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
    
    _titleLabel.text = NSLocalizedString(@"HomeView_title", nil);

    _facebookLoginLabel.text = NSLocalizedString(@"HomeView_facebook_label", nil);
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





#pragma mark - IBActions


- (IBAction) onFacebook:(id)sender
{
    // TAG ACTIVITY ALERT
    if ([YasoundSessionManager main].registered && [[YasoundSessionManager main].loginType isEqualToString:LOGIN_TYPE_FACEBOOK])
        [ActivityAlertView showWithTitle:NSLocalizedString(@"LoginView_alert_title", nil)];        
    
    [[YasoundSessionManager main] loginForFacebookWithTarget:self action:@selector(socialLoginReturned:)];
}



@end
