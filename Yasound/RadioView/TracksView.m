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
#import "BundleFileManager.h"
#import "Theme.h"

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
  self.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self updateView];
}

- (void)updateView
{
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MyYasoundBackground.png"]];
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
    UIView* view = [[UIView alloc] initWithFrame:cell.frame];
    view.backgroundColor = [UIColor clearColor];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"CellSeparator" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImage* image = [sheet image];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, cell.frame.size.height - image.size.height, sheet.frame.size.width, sheet.frame.size.height);
    [view addSubview:imageView];
    
    cell.backgroundView = view;
    [view release];
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
    cell.showsReorderControl = YES;
    
  
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


-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NextSong* song = [_data objectAtIndex:sourceIndexPath.row];
    [_data exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    [[YasoundDataProvider main] moveNextSong:song toPosition:destinationIndexPath.row target:self action:@selector(onUpdateTrack:info:)];  
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
    
//      // update tracks info display (order number...)
//      [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(onUpdateTrackAfterDelete:) userInfo:indexPath repeats:NO];

      [[YasoundDataProvider main] deleteNextSong:song target:self action:@selector(onUpdateTrack:info:)]; 
    
    return;
  }
  
}






//- (void)onUpdateTrack:(NSTimer*)timer
- (void)onUpdateTrack:(NSArray*)new_next_songs info:(NSDictionary*)info
{
    NSLog(@"onUpdateTrack");

    [self onNextSongsReceived:new_next_songs]; 
          
//    UITableViewCell* cell = [self cellForRowAtIndexPath:indexPath];
//    NextSong* song = [_data objectAtIndex:indexPath.row];
//    
//    song.order = [NSNumber numberWithInteger:(indexPath.row +1)];
//    
//    [self reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
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

