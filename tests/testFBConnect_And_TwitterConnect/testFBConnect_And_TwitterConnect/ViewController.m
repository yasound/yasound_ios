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
#import "Version/Version.h"


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
  [[FacebookSessionManager facebook] setTarget:self];
  [[TwitterSessionManager twitter] setTarget:self];

  [[FacebookSessionManager facebook] logout];
  [[TwitterSessionManager twitter] logout];
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
      message = @"facebook account NOT authorized!";
    else
      message = @"facebook account authorized!";
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Yasound" message:message delegate:self
                                       cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    [av release];  
  }
  
  if (_twitterBtnClicked)
  {
    if (![TwitterSessionManager twitter].authorized)
    {
      if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) 
        message = @"Twitter account NOT authorized!\nCheck the Twitter configuration in your device's Settings.";
      else
        message = @"Twitter account NOT authorized!";
    }
    else
      message = @"Twitter account authorized!";
    
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
  [[FacebookSessionManager facebook] setTarget:self];
  [[FacebookSessionManager facebook] login];
}




//.....................................
//
// connect using twitter account
//
- (IBAction)onTwitterConnect:(id)sender
{
  _twitterBtnClicked = YES;
  [[TwitterSessionManager twitter] setTarget:self];
  [[TwitterSessionManager twitter] login];
}


//.....................................
//
// get username
//
- (IBAction)onUsernameClicked:(id)sender
{
  if ([FacebookSessionManager facebook].authorized)
    [[FacebookSessionManager facebook] requestGetInfo:SRequestInfoUsername];

  else if ([TwitterSessionManager twitter].authorized)
    [[TwitterSessionManager twitter] requestGetInfo:SRequestInfoUsername];
}


//.....................................
//
// get friends list
//
- (IBAction)onFriendsClicked:(id)sender
{
  if ([FacebookSessionManager facebook].authorized)
    [[FacebookSessionManager facebook] requestGetInfo:SRequestInfoFriends];  
  
  else if ([TwitterSessionManager twitter].authorized)
    [[TwitterSessionManager twitter] requestGetInfo:SRequestInfoFriends];  
}

- (IBAction)onClearClicked:(id)sender
{
  [self logClear];
}


- (IBAction)onPostMessageClicked:(id)sender
{
  if ([FacebookSessionManager facebook].authorized)
  {
    NSString* message = [NSString stringWithFormat:@"%@ : test message from iPhone", [NSDate date]];
    
    [[FacebookSessionManager facebook] requestPostMessage:message title:@"MyTitle" picture:[[NSURL alloc] initWithString:@"http://www.ephotozine.com/articles/Elinchrom-DLite-4-kit-4453/images/DLite4.jpg"]];  
  }
    
}

- (IBAction)onShareEventClicked:(id)sender
{

}




#pragma mark - SessionDelegate

- (void)sessionDidLogin:(BOOL)authorized
{
  [self testAuthorizations];
}


- (void)sessionLoginFailed
{
  NSString* message = @"login failed!";
  
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


- (void)requestDidFailed:(SessionRequestType)requestType error:(NSError*)error
{
  if (requestType == SRequestPostMessage)
  {
    [self log:@"could not post the message to your wall."];
    [self log:[error localizedDescription]];
    [self log:[error description]];
  }  
}


- (void)requestDidLoad:(SessionRequestType)requestType data:(NSArray*)data;
{
  if (requestType == SRequestInfoUsername)
  {
    if ([data count] == 0)
    {
      assert(0);
      NSLog(@"requestDidLoad SRequestInfoUsername error.");
      return;
    }
    
    [self log:@"\nSRequestInfoUsername"];

    NSDictionary* dico = [data objectAtIndex:0];
    [self log:[NSString stringWithFormat:@"id: %@", [dico valueForKey:DATA_FIELD_ID]]];
    [self log:[NSString stringWithFormat:@"type: %@", [dico valueForKey:DATA_FIELD_TYPE]]];
    [self log:[NSString stringWithFormat:@"username: %@", [dico valueForKey:DATA_FIELD_USERNAME]]];
    [self log:[NSString stringWithFormat:@"name: %@", [dico valueForKey:DATA_FIELD_NAME]]];
    return;
  }

  
  
  if (requestType == SRequestInfoFriends)
  {
    if ([data count] == 0)
    {
      NSLog(@"requestDidLoad SRequestInfoFriends : no friends.");
      return;
    }

    for (NSDictionary* friend in data)
    {
      [self log:@"\nSRequestInfoFriends"];
      [self log:[NSString stringWithFormat:@"id: %@", [friend valueForKey:DATA_FIELD_ID]]];
      [self log:[NSString stringWithFormat:@"type: %@", [friend valueForKey:DATA_FIELD_TYPE]]];
      [self log:[NSString stringWithFormat:@"username: %@", [friend valueForKey:DATA_FIELD_USERNAME]]];
      [self log:[NSString stringWithFormat:@"name: %@", [friend valueForKey:DATA_FIELD_NAME]]];
    }
    
    return;
  }
  
  if (requestType == SRequestPostMessage)
  {
    [self log:@"\nSRequestInfoFriends"];
    [self log:@"the message has been post to your wall."];
  }
  
}









#pragma mark - UITextView

- (void)log:(NSString*)str
{
  NSLog(@"%@", str);
  _textView.text = [NSString stringWithFormat:@"%@\n%@", _textView.text, str];
  [_textView scrollRangeToVisible:NSMakeRange([_textView.text length], 0)];
}

- (void)logClear
{
  _textView.text = nil;
}




@end
