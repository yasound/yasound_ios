//
//  TwitterSigninViewController.m
//  testFBConnect_And_TwitterConnect
//
//  Created by LOIC BERTHELOT on 16/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TwitterSigninViewController.h"

@implementation TwitterSigninViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
}



#pragma mark - IBActions

- (IBAction)onCloseClicked:(id)sender
{
  [self dismissModalViewControllerAnimated:YES];
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
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}





#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == 0)
    return 2;
  
  if (section == 1)
    return 1;
  
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
  }
  
  if (indexPath.section == 0)
  {
    if (indexPath.row == 0)
      cell = _login;
    else if (indexPath.row == 1)
      cell = _password;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  
  else if (indexPath.section == 1)
    if (indexPath.row == 0)
      cell = _signin;
  
  return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//  ACAccount* account = [self.accounts objectAtIndex:[indexPath row]];
//  
//  [self.delegate twitterDidSelectAccount:account];
//  
//  [self dismissModalViewControllerAnimated:YES];
//  
//  //  TweetsListViewController *tweetsListViewController = [[TweetsListViewController alloc] init];
//  //  tweetsListViewController.account = [self.accounts objectAtIndex:[indexPath row]];
//  //  [self.navigationController pushViewController:tweetsListViewController animated:TRUE];
}







#pragma mark - TextField Delegate


- (void)textFieldDone:(UITextField*)textField
{
//  if (textField == _textFieldLogin)
//  {
//    [Cache cache].username = _textFieldLogin.text;
//    
//    NSError* error;
//    if (_textFieldPword.text != nil)
//      [Cache cache].password = _textFieldPword.text;
//  }
//  else if (textField == _textFieldPword)
//  {
//    NSError* error;
//    if (_textFieldLogin.text != nil)
//    {
//      [Cache cache].username = _textFieldLogin.text;
//      [Cache cache].password = _textFieldPword.text;
//    }
//  }
//  else
//  {
//    NSLog(@"Settings textField error.");
//    assert(0);
//  }
}






@end
