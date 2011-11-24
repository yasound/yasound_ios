//
//  RadioSelectionViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioSelectionViewController.h"
#import "RadioSelectionTableViewCell.h"

@implementation RadioSelectionViewController



- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabItem:(UITabBarSystemItem)tabItem
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) 
  {
    UITabBarItem* theItem = [[UITabBarItem alloc] initWithTabBarSystemItem:tabItem tag:0];
    self.tabBarItem = theItem;
    [theItem release];      
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
  }

  return self;
}


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabIcon:(NSString*)tabIcon
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
      UIImage* tabImage = [UIImage imageNamed:@"search.png"];
      UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:title image:tabImage tag:0];
      self.tabBarItem = theItem;
      [theItem release];      

      _tableView.delegate = self;
      _tableView.dataSource = self;
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

  _topBarTitle.text = self.title;

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


















#pragma mark - TableView Source and Delegate




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
  // Number of rows is the number of time zones in the region for the specified section.
  return 24;
}





- (void)tableView:(UITableView *)tableView willDisplayCell:(RadioSelectionTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
  float value = 235.f/255.f;
  if (indexPath.row & 1)
  {
    cell.backgroundColor = [UIColor colorWithRed:value  green:value blue:value alpha:1];
  }
  else
    cell.backgroundColor = [UIColor whiteColor];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{

  static NSString *cellIdentifier = @"RadioSelectionTableViewCell";

  RadioSelectionTableViewCell* cell = [[RadioSelectionTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier rowIndex:indexPath.row];
  
//  if (gGrayMask == nil)
//    gGrayMask = [UIImage imageNamed:@"MaskGray.png"];
//  
//  if (indexPath.row & 1)
//  {
//    [cell.radioAvatarMask setImage:[UIImage imageNamed:@"coeur.png"]];
//    NSLog(@"log : %@", cell.radioTitle.text);
//  }
  
  
  
//  static NSString *cellIdentifier = @"RadioSelectionTableViewCell";
//  RadioSelectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//  if (cell == nil) 
//  {
//    cell = [[RadioSelectionTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier];
//  }
//
//  if (gGrayMask == nil)
//    gGrayMask = [UIImage imageNamed:@"MaskGray.png"];
//
//  if (indexPath.row & 1)
//  {
//    [cell.radioAvatarMask setImage:[UIImage imageNamed:@"coeur.png"]];
////    NSLog(@"log : %@", cell.radioTitle.text);
//  }


  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}






@end
