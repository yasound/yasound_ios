//
//  SongsViewController.m
//  Yasound
//
//  Created by Jérôme BLONDON on 09/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongsViewController.h"
#import "YasoundDataProvider.h"
#import "ActivityAlertView.h"

@implementation SongsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil playlistId:(NSInteger)playlistId
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _playlistId = playlistId;
        _matchedSongs = [[NSMutableArray alloc] init ];
        [_matchedSongs retain];
        
        _unmatchedSongs = [[NSMutableArray alloc] init ];
        [_unmatchedSongs retain];
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
    [ActivityAlertView showWithTitle:NSLocalizedString(@"Alert_contact_server", nil)];
    [[YasoundDataProvider main] songsForPlaylist:_playlistId target:self action:@selector(receiveSongs:withInfo:)];
}

- (void)viewDidUnload
{
    [_matchedSongs release];
    [_unmatchedSongs release];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Private methods
- (void)buildSongsData:(NSArray *)songs
{
    for (Song *song in songs) {
        NSLog(@"song = %@, yasoundsong = %@", song.name, song.song);
        if ([song.song isKindOfClass:[NSNumber class]]) {
            [_matchedSongs addObject:song];
        } else {
            NSLog(@"unmatched!");
            [_unmatchedSongs addObject:song];
        }
    }
}

#pragma mark - TableView Source and Delegate


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    if (section == 0) {
        return NSLocalizedString(@"SongsView_unmatched_songs", nil);
    } 
    return NSLocalizedString(@"SongsView_matched_songs", nil);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == 0) {
        return [_unmatchedSongs count];
    }
    return [_matchedSongs count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{

    NSMutableArray *source = NULL;
    if (indexPath.section == 0) {
        source = _unmatchedSongs;
    } else if (indexPath.section == 1) {
        source = _matchedSongs;
    }
    
    static NSString* CellIdentifier = @"SongCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    Song *song = [source objectAtIndex:indexPath.row];
    cell.textLabel.text = song.name;
    NSLog(@"name = %@, id=%d", song.name, [song.id integerValue]);
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - YasoundDataProvider callbacks

- (void)receiveSongs:(NSArray*)songs withInfo:(NSDictionary*)info
{
    [self buildSongsData:songs];
    [_tableView reloadData];
    [ActivityAlertView close];
}


@end
