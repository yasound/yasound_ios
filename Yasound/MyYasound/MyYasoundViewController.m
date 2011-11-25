//
//  MyYasoundViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 25/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "MyYasoundViewController.h"
#import "RadioSelectionTableViewCell.h"




@implementation MyYasoundViewController

@synthesize viewContainer;
@synthesize viewMyYasound;
@synthesize viewSelection;


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabIcon:(NSString*)tabIcon
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
      UIImage* tabImage = [UIImage imageNamed:tabIcon];
      UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:title image:tabImage tag:0];
      self.tabBarItem = theItem;
      [theItem release];     
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

  _viewCurrent = self.viewMyYasound;
  [self.viewContainer addSubview:_viewCurrent];
  
  UISegmentedControl* control = (UISegmentedControl *) [_segmentBarButtonItem customView];
  
  [control setTitle:NSLocalizedString(@"myyaound_tab_myyasound", nil) forSegmentAtIndex:0];
  [control setTitle:NSLocalizedString(@"myyaound_tab_friends", nil) forSegmentAtIndex:1];
  [control setTitle:NSLocalizedString(@"myyaound_tab_favorites", nil) forSegmentAtIndex:2];
  
  [control addTarget:self 
                       action:@selector(onmSegmentClicked:)  
             forControlEvents:UIControlEventValueChanged];}

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

- (IBAction)onmSegmentClicked:(id)sender
{
  int clickedSegment = [sender selectedSegment];
  
  switch (clickedSegment)
  {
    case 0:
      [_viewCurrent removeFromSuperview];
      _viewCurrent = self.viewMyYasound;
      [self.viewContainer addSubview:_viewCurrent];
      break;
      
    case 1:
      [_viewCurrent removeFromSuperview];
      _viewCurrent = self.viewSelection;
      [self.viewContainer addSubview:_viewCurrent];
      break;
      
    case 2:
      [_viewCurrent removeFromSuperview];
      _viewCurrent = self.viewSelection;
      [self.viewContainer addSubview:_viewCurrent];
      break;
  }
  

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
  
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}



@end
