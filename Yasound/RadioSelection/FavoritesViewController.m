//
//  FavoritesViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 18/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "FavoritesViewController.h"
#import "RadioViewController.h"
#import "AudioStreamManager.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "YasoundDataProvider.h"
#import "RadioSelectionTableViewCell.h"
#import "ActivityModelessSpinner.h"


@implementation FavoritesViewController

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabIcon:(NSString*)tabIcon
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
//        UIImage* tabImage = [UIImage imageNamed:tabIcon];
//        UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:title image:tabImage tag:0];
//        self.tabBarItem = theItem;
//        [theItem release]; 
        
        _radios = nil;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)dealloc
{
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _toolbarTitle.text = NSLocalizedString(@"FavoritesView_title", nil);
    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);
    
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    
    
}


- (void)viewWillAppear:(BOOL)animated
{
    if ([AudioStreamManager main].currentRadio == nil)
        _nowPlayingButton.enabled = NO;
    
    [[YasoundDataProvider main] favoriteRadiosWithGenre:nil withTarget:self action:@selector(receiveRadios:info:)];
    [[ActivityModelessSpinner main] addRef];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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




- (void)receiveRadios:(NSArray*)radios info:(NSDictionary*)info
{
    NSError* error = [info valueForKey:@"error"];
    if (error)
    {
        NSLog(@"can't get radios: %@", error.domain);
        return;
    }
    
    _radios = radios;
    [[ActivityModelessSpinner main] removeRef];
    [_tableView reloadData];
}




#pragma mark - TableView Source and Delegate




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (!_radios)
        return 0;
    return _radios.count;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *cellIdentifier = @"RadioSelectionTableViewCell";
    
    if (!_radios)
        return nil;
    
    NSInteger rowIndex = indexPath.row;
    
    Radio* radio = [_radios objectAtIndex:rowIndex];
    
    RadioSelectionTableViewCell* cell = [[RadioSelectionTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier rowIndex:rowIndex radio:radio];
    return cell;   
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RadioSelectionTableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
    
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:cell.radio];
    [self.navigationController pushViewController:view animated:YES];
    [view release]; 
}










#pragma mark - IBActions

- (IBAction)nowPlayingClicked:(id)sender
{
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:[AudioStreamManager main].currentRadio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (IBAction)menuBarItemClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
