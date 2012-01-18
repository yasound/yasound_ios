//
//  FriendsViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 18/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "FriendsViewController.h"
#import "RadioViewController.h"
#import "AudioStreamManager.h"
#import "BundleFileManager.h"
#import "Theme.h"

@implementation FriendsViewController

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

    _toolbarTitle.text = NSLocalizedString(@"FriendsView_title", nil);
    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);

    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MyYasoundBackground.png"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([AudioStreamManager main].currentRadio == nil)
        _nowPlayingButton.enabled = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}











#pragma mark - TableView Source and Delegate




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 1;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//}



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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {   
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = @"test";
    
    
    return cell;    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}













#pragma mark - IBActions

- (IBAction)nowPlayingClicked:(id)sender
{
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:[AudioStreamManager main].currentRadio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

@end
