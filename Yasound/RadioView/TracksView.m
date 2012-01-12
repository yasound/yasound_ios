//
//  TracksView.m
//  testDragCells
//
//  Created by LOIC BERTHELOT on 21/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TracksView.h"
#import "YasoundDataProvider.h"
#import "NextSong.h"

@implementation TracksView



- (void)dealloc
{
    if (_data != nil)
        [_data release];
    [super dealloc];
}


- (void)loadView
{
  [self setEditing:YES];
    
  self.dataSource = self;
  self.delegate = self;
  self.scrollEnabled = NO;
  self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [self updateView];
}

- (void)updateView
{
    [[YasoundDataProvider main] nextSongsForUserRadioWithTarget:self action:@selector(onNextSongsReceived:)];
}

- (void)onNextSongsReceived:(NSArray*)nextSongs
{
    if (_data != nil)
    {
        [_data release];
        _data = nil;
    }
    
    _data = [[NSMutableArray alloc] initWithArray:nextSongs];
    [self reloadData];
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
    if (_data == nil)
        return 1;
    
  return [_data count];  
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
    if (cell == nil) 
    {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
  
    if (_data == nil)
    {
        cell.textLabel.text = NSLocalizedString(@"TracksView_no_tracks", nil);
        return cell;
    }
    
    NextSong* song = [_data objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%d - %@", [song.order integerValue], song.song.metadata.name];
    cell.detailTextLabel.text = song.song.metadata.artist_name;
  
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
      NextSong* song = [_data objectAtIndex:indexPath.row];
      
    NSLog(@"deleting '%@'", song.song.metadata.name);

    // update data
    [_data removeObjectAtIndex:indexPath.row];

    // update gui
    [self deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
    
      // update tracks info display (order number...)
      [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(onUpdateTrackAfterDelete:) userInfo:indexPath repeats:NO];
    
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
        NextSong* song = [_data objectAtIndex:indexPath.row];
        NSLog(@"selected '%@'", song.song.metadata.name);
        
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
        NextSong* song = [_data objectAtIndex:indexPath.row];
        NSLog(@"destination '%@'", song.song.metadata.name);

        // update data
        [_data exchangeObjectAtIndex:_selectedIndexPath.row withObjectAtIndex:indexPath.row];

        // update gui
        [self moveRowAtIndexPath:_selectedIndexPath  toIndexPath:indexPath];
        
        // update tracks info display (order number...)
        [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(onUpdateTrack:) userInfo:_selectedIndexPath repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(onUpdateTrack:) userInfo:indexPath repeats:NO];


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



- (void)onUpdateTrack:(NSTimer*)timer
{
    NSIndexPath* indexPath = timer.userInfo;
    
    NSLog(@"updateTrack %d", indexPath.row);
    
    UITableViewCell* cell = [self cellForRowAtIndexPath:indexPath];
    NextSong* song = [_data objectAtIndex:indexPath.row];
    
    song.order = [NSNumber numberWithInteger:(indexPath.row +1)];
    
    [self reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}


- (void)onUpdateTrackAfterDelete:(NSTimer*)timer
{
    NSIndexPath* theIndexPath = timer.userInfo;
    
    NSLog(@"onUpdateTrackAfterDelete %d", theIndexPath.row);

    for (int row = theIndexPath.row; row < _data.count; row++)
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        
        UITableViewCell* cell = [self cellForRowAtIndexPath:indexPath];
        NextSong* song = [_data objectAtIndex:indexPath.row];
        
        song.order = [NSNumber numberWithInteger:(row +1)];
        
        [self reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    }
    

}










@end

