//
//  ViewController.m
//  testFBConnect_And_TwitterConnect
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "ViewController.h"
#import "SessionManager.h"

@implementation ViewController





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
//   if (_twitterEngine)
//   {
//     NSString* message;
//     
//     if (![_twitterEngine isAuthorized])
//       message = @"you're not logged to twitter anymore!";
//     else
//       message = @"you're logged to twitter!";
//       
//     UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Yasound" message:message delegate:self
//                                        cancelButtonTitle:@"OK" otherButtonTitles:nil];
//     [av show];
//     [av release];     
//   }
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



- (IBAction)onTestClicked:(id)sender
{
  NSString* message;
  if (![SessionManager manager].authorized)
    message = @"NOT authorized!";
  else
    message = @"authorized!";
  
  UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Yasound" message:message delegate:self
                                     cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [av show];
  [av release];  

}

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
  
  
//  _facebook = [[Facebook alloc] initWithAppId:FB_App_Id andDelegate:self];
//  
//  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//  if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) 
//  {
//    _facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
//    _facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
//  }
//  
//  if (![_facebook isSessionValid]) 
//    [_facebook authorize:nil];
}









//.....................................
//
// connect using twitter account
//
- (IBAction)onTwitterConnect:(id)sender
{
  
  UIViewController* controller = [[SessionManager manager] twitterLoginDialog];
  [SessionManager manager].delegate = self;
  [self presentModalViewController:controller animated: YES];  

//  if ((_login.text == nil) || (_password.text == nil))
//  {
//    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Yasound" message:@"login and password are requested!" delegate:self
//                                       cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [av show];
//    [av release];  
//    return;
//  }

  
  
  
}





#pragma mark - SessionDelegate

- (void)loginDidFinish:(BOOL)authorized
{
  UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Yasound" message:@"authorized!" delegate:self
                                     cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [av show];
  [av release];  
  return;  
}







@end
