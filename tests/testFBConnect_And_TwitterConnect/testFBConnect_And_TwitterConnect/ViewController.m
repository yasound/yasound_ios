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




//.....................................
//
// connect using facebook account
//
- (IBAction)onFacebookConnect:(id)sender
{
  [[SessionManager manager] loginUsingFacebook:self];
}









//.....................................
//
// connect using twitter account
//
- (IBAction)onTwitterConnect:(id)sender
{
  [[SessionManager manager] loginUsingTwitter:self];
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
