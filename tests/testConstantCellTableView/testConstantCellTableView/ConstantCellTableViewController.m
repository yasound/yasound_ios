//
//  ConstantCellTableViewController.m
//  testConstantCellTableView
//
//  Created by LOIC BERTHELOT on 22/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ConstantCellTableViewController.h"

@implementation ConstantCellTableViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  _rectNowPlayingIsSet = NO;
  _viewNowPlaying = nil;
  _indexPathNowPlaying = nil;
  _viewNowPlayingPosition = CCPPositionNone;
  _scrollviewLastPosY = 0;

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












#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 24;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString* CellIdentifier = @"Cell";

  if (indexPath.row == 11)
  {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NowPlayingTableViewCell"];
    if (cell == nil) 
    {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"NowPlayingTableViewCell"];
    }
    
    cell  = [self configureNowPlayingCell:@"now playing : Gerard Lenorman"];
    _cellNowPlaying = cell;
    if (_indexPathNowPlaying)
      [_indexPathNowPlaying release];
    
    _indexPathNowPlaying = indexPath;
    [_indexPathNowPlaying retain];
    
    //NSLog(@"cell 's tag : %d", cell.tag);
    
    return cell;
  
  }
  else if ((indexPath.row == 8) || (indexPath.row == 14) || (indexPath.row == 19))
  {
    NSString* cellIdentifier;
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    
    cellIdentifier = @"PlayedTableViewCell";
    if (indexPath.row == 8)
      label.text = @"played at 12h30 : Bidule Machin";
    else if (indexPath.row == 14)
      label.text = @"played at 11h30 : Trouloulou";
    else
      label.text = @"played at 10h30 : Houpla houpla houp";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) 
    {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }

    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
    cell = [topLevelObjects objectAtIndex:0];
    [cell addSubview:label];
    
    //NSLog(@"cell 's tag : %d", cell.tag);
    
    return cell;
  }
  else
  {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"yasound %d", indexPath.row];
    return cell;
  }

  return nil;
}




- (UIView*)configureNowPlayingCell:(NSString*)title
{
  UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
  label.backgroundColor = [UIColor clearColor];
  label.textColor = [UIColor whiteColor];

  label.text = [NSString stringWithString:title];

  NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NowPlayingTableViewCell" owner:self options:nil];
  UIView* view = [topLevelObjects objectAtIndex:0];
  [view addSubview:label];
  
  return view;
  //NSLog(@"cell 's tag : %d", cell.tag);
}




#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}





#pragma mark -
#pragma mark ScrollView Callbacks


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
  NSLog(@"scrollViewWillBeginDragging");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
	if (scrollView.isDragging)
  {
    ConstantCellDirection direction = (scrollView.contentOffset.y < _scrollviewLastPosY)? CCPDown : CCPUp;
    _scrollviewLastPosY = scrollView.contentOffset.y;
    
    CGFloat posMin = scrollView.contentOffset.y;
    //LBDEBUG
    CGFloat posMax = scrollView.contentOffset.y + scrollView.bounds.size.height;
    
    CGRect rectMin = CGRectMake(0, posMin, 320, 44);
    
    if (!_rectNowPlayingIsSet && _indexPathNowPlaying)
    {
      _rectNowPlaying = [_tableView rectForRowAtIndexPath:_indexPathNowPlaying];
      _rectNowPlayingIsSet = YES;
    }
    
    //LBDEBUG
    NSString* directionStr = (direction == CCPUp) ? @"UP" : @"DOWN";
    NSLog(@"direction %@  _rectNowPlaying %.2f -> %.2f     posMax %.2f", directionStr, _rectNowPlaying.origin.y, _rectNowPlaying.origin.y + _rectNowPlaying.size.height, posMax);
//    NSLog(@"s %.2f   v %.2f", );
    
    if (_rectNowPlayingIsSet && !_viewNowPlaying && (direction == CCPUp) && CGRectContainsPoint(_rectNowPlaying, CGPointMake(0, posMin)))
    {
      _viewNowPlayingPosition = CCPTop;
      
      _viewNowPlayingPosY = posMin;
      _viewNowPlaying = [self configureNowPlayingCell:@"now playing : Gerard Lenorman"];
      _viewNowPlaying.frame = CGRectMake(0, 0, _viewNowPlaying.frame.size.width, _viewNowPlaying.frame.size.height);
      [self.view addSubview:_viewNowPlaying];
    }
    else if (_rectNowPlayingIsSet && !_viewNowPlaying && (direction == CCPDown) && CGRectContainsPoint(_rectNowPlaying, CGPointMake(0, posMax)))
    {
      _viewNowPlayingPosition = CCPBottom;

      //LBDEBUG
      NSLog(@"FLAG 1");
      
      _viewNowPlayingPosY = posMax;
      _viewNowPlaying = [self configureNowPlayingCell:@"now playing : Gerard Lenorman"];
      _viewNowPlaying.frame = CGRectMake(0, 480 - 64, _viewNowPlaying.frame.size.width, _viewNowPlaying.frame.size.height);
      [self.view addSubview:_viewNowPlaying];
    }
    
    else if ((_viewNowPlayingPosition == CCPTop) && (posMin < _viewNowPlayingPosY))
    {
      //LBDEBUG
      NSLog(@"FLAG 2");

      _viewNowPlayingPosition = CCPPositionNone;
      [_viewNowPlaying removeFromSuperview];
      _viewNowPlaying = nil;
    }

    else if ((_viewNowPlayingPosition == CCPBottom) && (posMax > _viewNowPlayingPosY))
    {
      //LBDEBUG
      NSLog(@"FLAG 3");

      _viewNowPlayingPosition = CCPPositionNone;
      [_viewNowPlaying removeFromSuperview];
      _viewNowPlaying = nil;
    }

        
//    if (scrollView.contentOffset.y > -DRAGGABLE_HEIGHT && scrollView.contentOffset.y < 0.0f) 
//    {
//      self.draggableTableView.frame = CGRectMake(0,  -DRAGGABLE_HEIGHT - scrollView.contentOffset.y, self.draggableTableView.frame.size.width, self.draggableTableView.frame.size.height);
//    } 
//    else if (scrollView.contentOffset.y < -DRAGGABLE_HEIGHT) 
//    {
//    }
	}
}










@end
