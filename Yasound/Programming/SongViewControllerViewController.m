//
//  SongViewControllerViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongViewControllerViewController.h"


#define NB_ROWS 6
#define ROW_NAME 0
#define ROW_ARTIST 1
#define ROW_ALBUM 2
#define ROW_NBLIKES 3
#define ROW_LAST_READ 4
#define ROW_FREQUENCY 5


@implementation SongViewControllerViewController


@synthesize song;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil song:(Song*)song
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.song = song;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}








#pragma mark - TableView Source and Delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //    return gIndexMap.count;
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return NB_ROWS;
}



//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{    
//    return 44;
//}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellPlainRow.png"]];
    cell.backgroundView = view;
    [view release];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (indexPath.row == ROW_NAME)
    {
        cell.textLabel.text = NSLocalizedString(@"SongView_name", nil);
        cell.detailTextLabel.text = song.name;
    }
    else if (indexPath.row == ROW_ARTIST)
    {
        cell.textLabel.text = NSLocalizedString(@"SongView_name", nil);
        cell.detailTextLabel.text = song.name;
    }
    else if (indexPath.row == ROW_ALBUM)
    {
        cell.textLabel.text = NSLocalizedString(@"SongView_name", nil);
        cell.detailTextLabel.text = song.name;
    }
    else if (indexPath.row == ROW_NBLIKES)
    {
        cell.textLabel.text = NSLocalizedString(@"SongView_name", nil);
        cell.detailTextLabel.text = song.name;
    }
    else if (indexPath.row == ROW_LAST_READ)
    {
        cell.textLabel.text = NSLocalizedString(@"SongView_name", nil);
        cell.detailTextLabel.text = song.name;
    }
    else if (indexPath.row == ROW_FREQUENCY)
    {
        cell.textLabel.text = NSLocalizedString(@"SongView_name", nil);
        cell.detailTextLabel.text = song.name;
    }


    
    Song* song = [self.matchedSongs objectAtIndex:indexPath.row];
    
    cell.textLabel.text = song.name;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", song.album, song.artist];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1];
    
    
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

@end
