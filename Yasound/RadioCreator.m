//
//  RadioCreator.m
//  Yasound
//
//  Created by Sébastien Métrot on 11/1/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioCreator.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation RadioCreator

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
      // Custom initialization
    
      MPMediaQuery *playlistsquery = [MPMediaQuery playlistsQuery];
      
      NSLog(@"Logging items from a generic query...");
      lists = [playlistsquery collections];
      for (MPMediaPlaylist *list in lists)
      {
        NSString *listTitle = [list valueForProperty: MPMediaPlaylistPropertyName];
        NSLog (@"%@", listTitle);
      }
      NSLog(@"Done Logging items from a generic query...");

      // Empty selection:
      selectedLists = [[NSMutableSet alloc] init];
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
    // Do any additional setup after loading the view from its nib.
  radioName.text = [[UIDevice currentDevice] name];
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

- (IBAction)CreateRadio:(id)sender
{
  NSLog(@"Create Radio!\n");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // Number of rows is the number of time zones in the region for the specified section.
  return [lists count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  // The header for the section is the region name -- get this from the region at the section index.
  return @"Select playlists";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *MyIdentifier = @"MyIdentifier";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
  }
 
  MPMediaPlaylist* item = [lists objectAtIndex: indexPath.row];
  cell.textLabel.text = [item valueForProperty:MPMediaPlaylistPropertyName];
  if ([selectedLists containsObject:item])
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  else
    cell.accessoryType = UITableViewCellAccessoryNone;
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [playlists cellForRowAtIndexPath:indexPath];
  MPMediaPlaylist* item = [lists objectAtIndex: indexPath.row];
  
  if (YES == [selectedLists containsObject:item])
  {
    NSLog(@"deselect\n");
    [selectedLists removeObject:item];
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
  else
  {
    NSLog(@"select\n");
    [selectedLists addObject:item];
    cell.accessoryType = UITableViewCellAccessoryCheckmark; 
  }
  
  cell.selected = FALSE;
}

@end
