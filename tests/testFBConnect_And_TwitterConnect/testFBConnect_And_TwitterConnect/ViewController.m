//
//  ViewController.m
//  testFBConnect_And_TwitterConnect
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize facebookConnected;
@synthesize twitterConnected;



#define kOAuthConsumerKey        @"Your consumer key here"         //REPLACE With Twitter App OAuth Key  
#define kOAuthConsumerSecret    @"Your consumer secret here"     //REPLACE With Twitter App OAuth Secret  


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [_facebookBtn addTarget:self action:@selector(onFacebookConnect:) forControlEvents:UIControlEventTouchUpInside];
  [_twitterBtn addTarget:self action:@selector(onTwitterConnect:) forControlEvents:UIControlEventTouchUpInside];
  
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
  
    [_engine release]; 
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}



#pragma mark - IBActions


//.....................................
//
// connect using facebook account
//
- (IBAction)onFacebookConnect:(id)sender
{
  if ((_login.text == nil) || (_password.text == nil))
  {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Yasound" message:@"login and password are requested!" delegate:self
                                       cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    [av release];  
    return;
  }
}


//.....................................
//
// connect using twitter account
//
- (IBAction)onTwitterConnect:(id)sender
{
  
  if(!_engine){  
    _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];  
    _engine.consumerKey    = kOAuthConsumerKey;  
    _engine.consumerSecret = kOAuthConsumerSecret;  
  }  
  
  if(![_engine isAuthorized])
  {  
    UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];  
    
    if (controller){  
      [self presentModalViewController: controller animated: YES];  
    }  
  }  
  
  return;
  
  if ((_login.text == nil) || (_password.text == nil))
  {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Yasound" message:@"login and password are requested!" delegate:self
                                       cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    [av release];  
    return;
  }
  
  
  
  
  
  
}









@end
