//
//  ViewController.m
//  testDragCells
//
//  Created by LOIC BERTHELOT on 21/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

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
	// Do any additional setup after loading the view, typically from a nib.
  
  
//  _gestureBegan = NO;
//  _gestureEnded = NO;

  
//  UIPanGestureRecognizer* panGesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureMoveAround:)] autorelease];
//  [panGesture setMaximumNumberOfTouches:1];
////  [panGesture setDelegate:self];
//  [self.view addGestureRecognizer:panGesture];
  
  
  [_tableView setEditing:YES];
  _tableView.dataSource = _tableView;
  _tableView.delegate = _tableView;
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





////................................................................................................................................
////
//// UITableViewDataSource 
////
//
//#pragma mark - UITableViewDataSource
//
//
//
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
//{
//  return 1;
//}
//
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
//{
//  return 6;  
//}


//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
//{
//  
//}



//// Customize the appearance of table view cells.
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
//{
//  static NSString *CellIdentifier = @"Cell";
//  
//  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//  if (cell == nil) 
//  {
//    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//  }
//  
//  cell.textLabel.text = [NSString stringWithFormat:@"cell %d", indexPath.row];
//  
//  return cell;
//}












//................................................................................................................................
//
// UITableViewDelegate
//


//#pragma mark - UITableViewDelegate
//
//
//// cell selection
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//  NSLog(@"didSelectRowAtIndexPath %d", indexPath.row);
//  _selectedRow = indexPath;
//
//}






//
//#pragma mark - touches actions
//
//
//
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
//{
////  UITouch *aTouch = [touches anyObject];
////  
////  if (aTouch.tapCount == 2) 
////  {
////    [NSObject cancelPreviousPerformRequestsWithTarget:[self touchesDelegate]];
////    _handlesDoubleTap = YES;
////  }
////  else
////    _handlesDoubleTap = NO;
//  NSLog(@"touchesBegan");
//  [super touchesBegan:touches withEvent:event];
//  
//}
//
//
//
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
//{
//  NSLog(@"touchesMoved");
//  [super touchesMoved:touches withEvent:event];
//  
//}
//
//
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
//{
//  NSLog(@"touchesEnded");
//  [super touchesEnded:touches withEvent:event];
////  UITouch *theTouch = [touches anyObject];
////  
////  
////  if (!_handlesDoubleTap && theTouch.tapCount == 1) 
////  {
////    NSDictionary *touchLoc = [NSDictionary dictionaryWithObject:
////                              [NSValue valueWithCGPoint:[theTouch locationInView:self]] forKey:@"location"];
////    [[self touchesDelegate] performSelector:@selector(handleSingleTap:) withObject:touchLoc afterDelay:0.25];
////  } 
////  
////  else if (theTouch.tapCount == 2) 
////  {
////    [UIView beginAnimations:nil context:NULL];
////    if (self.zoomScale == self.minimumZoomScale)
////      self.zoomScale = self.maximumZoomScale;
////    else
////      self.zoomScale = self.minimumZoomScale;
////    [UIView commitAnimations];
////    
////  }
//}
//
//
//UITapGestureRecognizer
//
//
//
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
//{
//  /* no state to clean up, so null implementation */
//  [super touchesCancelled:touches withEvent:event];
//}







//-(void)panGestureMoveAround:(UIPanGestureRecognizer *)gesture;
//{
////  UIView *piece = [gesture view];
//  
////  [self adjustAnchorPointForGestureRecognizer:gesture];
//  
//  if ([gesture state] == UIGestureRecognizerStateBegan || [gesture state] == UIGestureRecognizerStateChanged) 
//  {
//    
//    CGPoint translation = [gesture translationInView:[gesture view]];
//    CGPoint location  = [gesture locationInView:[gesture view]];
//    
////    NSLog(@"translation : %.2f, %.2f", translation.x, translation.y);
////    NSLog(@"location : %.2f, %.2f", location.x, location.y);
////    [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y+translation.y*0.1)];
////    [gesture setTranslation:CGPointZero inView:[piece superview]];
//    
////    rectForRowAtIndexPath
//  }
//}



- (IBAction)onButtonClicked:(id)sender
{
  NSIndexPath* src = [NSIndexPath indexPathForRow:4 inSection:0];
  NSIndexPath* dst = [NSIndexPath indexPathForRow:2 inSection:0];
  [_tableView moveRowAtIndexPath:src  toIndexPath:dst];
}
















@end

