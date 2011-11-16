//
//  ViewController.m
//  testFBConnect_And_TwitterConnect
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "ViewController.h"
#import "FacebookSessionManager.h"
#import "TwitterSessionManager.h"

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
  
  _facebookBtnClicked = NO;
  _twitterBtnClicked = NO;
  
  
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
  [self testAuthorizations];
}


- (void)testAuthorizations
{
  NSString* message;
  
  if (_facebookBtnClicked)
  {
    if (![FacebookSessionManager facebook].authorized)
      message = @"facebook NOT authorized!";
    else
      message = @"facebook authorized!";
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Yasound" message:message delegate:self
                                       cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    [av release];  
  }
  
  if (_twitterBtnClicked)
  {
    if (![TwitterSessionManager twitter].authorized)
      message = @"twitter NOT authorized!";
    else
      message = @"twitter authorized!";
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Yasound" message:message delegate:self
                                       cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    [av release];  
  }
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
  _facebookBtnClicked = YES;
  [[FacebookSessionManager manager] login:self];
}









//.....................................
//
// connect using twitter account
//
- (IBAction)onTwitterConnect:(id)sender
{
  _twitterBtnClicked = YES;
  [[TwitterSessionManager manager] login:self];
}





#pragma mark - SessionDelegate

- (void)sessionDidLogin:(BOOL)authorized
{
  [self testAuthorizations];
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
