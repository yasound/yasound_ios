//
//  PullViewController.m
//  testPullViewController
//
//  Created by LOIC BERTHELOT on 21/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PullViewController.h"

@implementation PullViewController


@synthesize draggableTableView;



#define DRAGGABLE_HEIGHT 176.f

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  NSArray* nibViews =  [[NSBundle mainBundle] loadNibNamed:@"DraggableTableView" owner:self options:nil];
  self.draggableTableView = (DraggableTableView*)[nibViews objectAtIndex:0];
  
  self.draggableTableView.frame = CGRectMake(0.0f, 0.0f - DRAGGABLE_HEIGHT, 320.0f, DRAGGABLE_HEIGHT);
  
  [self.view addSubview:self.draggableTableView];
  
  
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








#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Return the number of sections.
  return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
  // Return the number of rows in the section.
  return 24;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
  cell.backgroundColor = [UIColor whiteColor];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
  
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  }
  
  cell.textLabel.text = [NSString stringWithFormat:@"cell element %d", indexPath.row];
  
  return cell;
}




 

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
  
}







#pragma mark -
#pragma mark ScrollView Callbacks
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
	if (scrollView.isDragging)
  {
    if (scrollView.contentOffset.y > -DRAGGABLE_HEIGHT && scrollView.contentOffset.y < 0.0f) 
    {
      self.draggableTableView.frame = CGRectMake(0,  -DRAGGABLE_HEIGHT - scrollView.contentOffset.y, self.draggableTableView.frame.size.width, self.draggableTableView.frame.size.height);
    } 
    else if (scrollView.contentOffset.y < -DRAGGABLE_HEIGHT) 
    {
    }
	}
}


#define DRAGGABLE_THRESHOLD 100.f

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (scrollView.contentOffset.y <= -DRAGGABLE_THRESHOLD) 
  {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
    self.draggableTableView.frame = CGRectMake(0, 0, self.draggableTableView.frame.size.width, self.draggableTableView.frame.size.height);
		[UIView commitAnimations];

		_tableView.contentInset = UIEdgeInsetsMake(DRAGGABLE_HEIGHT, 0.0f, 0.0f, 0.0f);
	}
  else
  {
		_tableView.contentInset = UIEdgeInsetsMake(0.f, 0.0f, 0.0f, 0.0f);  

		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];

    self.draggableTableView.frame = CGRectMake(0, -DRAGGABLE_HEIGHT, self.draggableTableView.frame.size.width, self.draggableTableView.frame.size.height);
    
		[UIView commitAnimations];
  }
}







@end
