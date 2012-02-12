//
//  RadioSelectionViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioSelectionViewController.h"
#import "RadioSelectionTableViewCell.h"
#import "StyleSelectorViewController.h"
#import "RadioViewController.h"
#import "YasoundDataProvider.h"
#import "AudioStreamManager.h"
#import "BundleFileManager.h"
#import "Theme.h"

@implementation RadioSelectionViewController


//#define TEST_FAKE 0


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil  title:(NSString*)title tabIcon:(NSString*)tabIcon
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        //      _type = type;
        
        UIImage* tabImage = [UIImage imageNamed:tabIcon];
        UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:title image:tabImage tag:0];
        self.tabBarItem = theItem;
        [theItem release];      
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"RadioSlectionViewController dealloc");
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
    
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MenuBackground" error:nil];    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
    
    //  _topBarTitle.text = NSLocalizedString(@"FavoritesView_title", nil);
    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);
    
    [_qualitySwitchLabel loadView];
    
    // now playing button
    //    UIButton* btn = [[UIButton alloc] initWithFrame:frame];
    
    
    NSString* str;
    
    _currentStyle = @"style_all";
    _categoryTitle.text = NSLocalizedString(_currentStyle, nil) ;

#ifdef TEST_FAKE
    _radios = [[NSMutableArray alloc] init];
    [_radios retain];
    for (int i = 0; i < 32; i++)
    {
        Radio* radio = [[Radio alloc] init];
        radio.name = [NSString stringWithFormat:@"radio %d", i];
        radio.genre = [NSString stringWithFormat:@"genre %d", i];
        radio.picture = nil;
        radio.likes = [NSNumber numberWithInteger:456];
        radio.favorites = [NSNumber numberWithInteger:654];
        
        [_radios addObject:radio];
    }
    
    [_tableView reloadData];
#endif
    
    
    [self updateRadios:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([AudioStreamManager main].currentRadio == nil)
        [_nowPlayingButton setEnabled:NO];
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
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];
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
    if (!_radios)
        return 0;
    return [_radios count];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSInteger rowIndex = indexPath.row;
    UIImageView* imageView = nil;
    
    // cell background
    if (rowIndex & 1)
    {
        imageView = [[[BundleFileManager main] stylesheetForKey:@"RadioSelectionBackgroundLight"  retainStylesheet:YES overwriteStylesheet:NO error:nil] makeImage];
    }
    else
    {
        imageView = [[[BundleFileManager main] stylesheetForKey:@"RadioSelectionBackgroundDark"  retainStylesheet:YES overwriteStylesheet:NO error:nil] makeImage];
    }
    
    cell.backgroundView = imageView;

}





- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *cellIdentifier = @"RadioSelectionTableViewCell";
    
    if (!_radios)
        return nil;
    
    RadioSelectionTableViewCell* cell = (RadioSelectionTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    NSInteger rowIndex = indexPath.row;
    Radio* radio = [_radios objectAtIndex:rowIndex];
    
    if (cell == nil)
    {    
        cell = [[RadioSelectionTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier rowIndex:rowIndex radio:radio];
    }
    else
        [cell updateWithRadio:radio rowIndex:rowIndex];
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RadioSelectionTableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
    
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:cell.radio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];  
}






#pragma  mark - Update

- (void)updateRadios:(NSString*)genre
{
    NSString* g = genre;
    if ([genre isEqualToString:@"style_all"])
        g= nil;
    [[YasoundDataProvider main] topRadiosWithGenre:g withTarget:self action:@selector(receiveRadios:withInfo:)];
}




- (void)receiveRadios:(NSArray*)radios withInfo:(NSDictionary*)info
{
#ifdef TEST_FAKE
    return;
#endif
    
    NSError* error = [info valueForKey:@"error"];
    if (error)
    {
        NSLog(@"can't get radios: %@", error.domain);
        return;
    }
    
    _radios = radios;
    [_tableView reloadData];
}







#pragma mark - IBActions

- (IBAction)onStyleSelectorClicked:(id)sender
{
    StyleSelectorViewController* view = [[StyleSelectorViewController alloc] initWithNibName:@"StyleSelectorViewController" bundle:nil currentStyle:_currentStyle target:self];
    //  self.navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self.navigationController presentModalViewController:view animated:YES];
}


- (IBAction)onNowPlayingClicked:(id)sender
{
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:[AudioStreamManager main].currentRadio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (IBAction)menuBarItemClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}






#pragma mark - StyleSelectorDelegate

- (void)didSelectStyle:(NSString*)style
{
    //  [self.navigationController dismissModalViewControllerAnimated:YES];
    
    _currentStyle = style;
    _categoryTitle.text = NSLocalizedString(_currentStyle, nil);
    
    [self updateRadios:_currentStyle];
}

- (void)closeSelectStyleController
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}



@end
