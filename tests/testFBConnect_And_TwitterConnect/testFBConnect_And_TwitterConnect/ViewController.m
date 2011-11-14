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
  
  [SessionManager manager].delegate = self;
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


- (IBAction)onLogoutClicked:(id)sender
{
  [[SessionManager manager] logout];
}


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





- (IBAction)textFieldDoneEditing:(id)sender
{
  [sender resignFirstResponder];

}

//-(IBAction) backgroundTap:(id) sender
//{
//  [self.tfUsername resignFirstResponder];
//}


//- (void)textFieldDone:(UITextField*)textField
//{
//
//}





//.....................................
//
// connect using facebook account
//
- (IBAction)onFacebookConnect:(id)sender
{
  NSLog(@"click '%@' '%@' ", _login.text, _password.text);
  
  if ((_login.text.length == 0) || (_password.text.length == 0))
  {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Yasound" message:@"login and password are requested!" delegate:self
                                       cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    [av release];  
    return;
  }
  
  [[SessionManager manager] loginUsingFacebook:_login.text password:_password.text];
}









//.....................................
//
// connect using twitter account
//
- (IBAction)onTwitterConnect:(id)sender
{
  
  UIViewController* controller = [[SessionManager manager] twitterLoginDialog];
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

- (void)sessionDidLogin:(BOOL)authorized
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


- (void)sessionDidLogout
{
  NSString* message = @"logout done.";
  
  UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Yasound" message:message delegate:self
                                     cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [av show];
  [av release];  
}








@end
