//
//  DraggableTableView.m
//  testDragCells
//
//  Created by LOIC BERTHELOT on 21/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DraggableTableView.h"

@implementation DraggableTableView

@synthesize data;





- (void) awakeFromNib
{
  [super awakeFromNib];
  
  data = [[NSMutableArray alloc] initWithObjects:@"cell 0", @"cell 2", @"cell 3", @"cell 4", @"cell 5", @"cell 6", nil];
  
  [self setEditing:YES];
  self.dataSource = self;
  self.delegate = self;
  self.scrollEnabled = NO;
  self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}



//................................................................................................................................
//
// UITableViewDataSource 
//

#pragma mark - UITableViewDataSource




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
  return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
  return [self.data count];  
}


//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
//{
//  
//}



// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) 
  {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  }
  
  cell.textLabel.text = [self.data objectAtIndex:indexPath.row];
  
  return cell;
}












//................................................................................................................................
//
// UITableViewDelegate
//


#pragma mark - UITableViewDelegate


// cell selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSLog(@"didSelectRowAtIndexPath %d", indexPath.row);
//  _selectedRow = indexPath;

}


- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete)
  {
    NSLog(@"deleting '%@'", [self.data objectAtIndex:indexPath.row]);

    // update data
    [self.data removeObjectAtIndex:indexPath.row];

    // update gui
    [self deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
    
    
    return;
  }
  
}




#pragma mark - touches actions




- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
  //NSLog(@"touchesBegan");
  
  UITouch *aTouch = [touches anyObject];
  CGPoint touchPoint = [aTouch locationInView:self];
  
  BOOL done = NO;
  NSInteger row = 0;
  NSInteger nbCells = [self numberOfRowsInSection:0];
  while (!done && (row < nbCells))
  {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    CGRect rect = [self rectForRowAtIndexPath:indexPath];

    if (CGRectContainsPoint(rect, touchPoint))
    {
      NSLog(@"selected %@", [self.data objectAtIndex:row]);
      _selectedIndexPath = indexPath;
      [_selectedIndexPath retain];
      done = YES;
    }
    
    row++;
  }
  
  [super touchesBegan:touches withEvent:event];
  
}




- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
  //NSLog(@"touchesMoved");
  
  if (_selectedIndexPath == nil)
  {
    [super touchesMoved:touches withEvent:event];
    return;
  }
  
  UITouch *aTouch = [touches anyObject];
  CGPoint touchPoint = [aTouch locationInView:self];

  
  BOOL done = NO;
  NSInteger row = 0;
  NSInteger nbCells = [self numberOfRowsInSection:0];
  while (!done && (row < nbCells))
  {
    if (row == _selectedIndexPath.row)
    {
      row++;
      continue;
    }
    

    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    CGRect rect = [self rectForRowAtIndexPath:indexPath];
    
    if (CGRectContainsPoint(rect, touchPoint))
    {
      NSLog(@"destination %@", [self.data objectAtIndex:indexPath.row]);
      
      // update data
      [self.data exchangeObjectAtIndex:_selectedIndexPath.row withObjectAtIndex:indexPath.row];
      
      // update gui
      [self moveRowAtIndexPath:_selectedIndexPath  toIndexPath:indexPath];
      _selectedIndexPath = indexPath;

      
      done = YES;
    }
    
    row++;
  }

  
  
  [super touchesMoved:touches withEvent:event];
  
}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
  // NSLog(@"touchesEnded");
  
  [_selectedIndexPath release];
  _selectedIndexPath = nil;
  
  [super touchesEnded:touches withEvent:event];
}




- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
{
  /* no state to clean up, so null implementation */
  [super touchesCancelled:touches withEvent:event];
}

















@end

