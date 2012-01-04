//
//  MyYasoundViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 25/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "MyYasoundViewController.h"
#import "RadioSelectionTableViewCell.h"
#import "BundleFileManager.h"
#import "RadioViewController.h"


@implementation MyYasoundViewController

@synthesize viewContainer;
@synthesize viewMyYasound;
@synthesize viewSelection;



//LBDEBUG
NSArray* gFakeUsersFriends = nil;
NSArray* gFakeUsersFavorites = nil;



- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabIcon:(NSString*)tabIcon
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
      UIImage* tabImage = [UIImage imageNamed:tabIcon];
      UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:title image:tabImage tag:0];
      self.tabBarItem = theItem;
      [theItem release];   
      
      // LBDEBUG static init
      if (gFakeUsersFriends == nil)
      {
        NSDictionary* resources = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Resources"];
        gFakeUsersFriends = [resources objectForKey:@"fakeUsersFriends"];
        gFakeUsersFavorites = [resources objectForKey:@"fakeUsersFavorites"];
      }
      ///////////////

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
    [self deallocInSettingsTableView];
    [self deallocInRadioSelection];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    BundleStylesheet* stylesheet = [[BundleFileManager main] stylesheetForKey:@"GuiTintColor" error:nil];
    _toolbar.tintColor = stylesheet.color;


    _viewCurrent = self.viewMyYasound;
    [self.viewContainer addSubview:_viewCurrent];

    _segmentControl = (UISegmentedControl *) [_segmentBarButtonItem customView];

    [_segmentControl setTitle:NSLocalizedString(@"myyaound_tab_myyasound", nil) forSegmentAtIndex:0];
    [_segmentControl setTitle:NSLocalizedString(@"myyaound_tab_friends", nil) forSegmentAtIndex:1];
    [_segmentControl setTitle:NSLocalizedString(@"myyaound_tab_favorites", nil) forSegmentAtIndex:2];

    [_segmentControl addTarget:self action:@selector(onmSegmentClicked:) forControlEvents:UIControlEventValueChanged];
    
    [self viewDidLoadInSettingsTableView];    
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
    
    // automatic launch
    BOOL _automaticLaunch =  [[[NSUserDefaults standardUserDefaults] objectForKey:@"automaticLaunch"] boolValue];
    
    if (_automaticLaunch)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"automaticLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // display radio automatically
        RadioViewController* view = [[RadioViewController alloc] init];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }

    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_settingsTableView deselectRowAtIndexPath:[_settingsTableView indexPathForSelectedRow] animated:NO];    
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];    
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}









#pragma mark - IBActions

- (IBAction)onmSegmentClicked:(id)sender
{
  switch (_segmentControl.selectedSegmentIndex)
  {
    case 0:
      [_viewCurrent removeFromSuperview];
      _viewCurrent = self.viewMyYasound;
      [self.viewContainer addSubview:_viewCurrent];
      break;
      
    case 1:
      [_viewCurrent removeFromSuperview];
      _viewCurrent = self.viewSelection;
      [self.viewContainer addSubview:_viewCurrent];
      [_tableView reloadData];
      break;
      
    case 2:
      [_viewCurrent removeFromSuperview];
      _viewCurrent = self.viewSelection;
      [self.viewContainer addSubview:_viewCurrent];
      [_tableView reloadData];
      break;
  }
  

}






#pragma mark - TableView Source and Delegate


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
//{
//    if (tableView == _settingsTableView)
//        return [self titleInSettingsTableViewForHeaderInSection:section];
//    
//    return nil;
//}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _settingsTableView)
        return [self numberOfSectionsInSettingsTableView];
    
    return [self numberOfSectionsInSelectionTableView];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (tableView == _settingsTableView)
        return [self numberOfRowsInSettingsTableViewSection:section];
        
    return [self numberOfRowsInSelectionTableViewSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _settingsTableView)
        return [self heightInSettingsForRowAtIndexPath:indexPath];
    
    return 44;
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (tableView == _settingsTableView)
        [self willDisplayCellInSettingsTableView:cell forRowAtIndexPath:indexPath];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (tableView == _settingsTableView)
        return [self cellInSettingsTableViewForRowAtIndexPath:indexPath];
    
    return [self cellInSelectionTableViewForRowAtIndexPath:indexPath];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _settingsTableView)
    {
        [self didSelectInSettingsTableViewRowAtIndexPath:indexPath];
        return;
    }
    
    [self didSelectInSelectionTableViewRowAtIndexPath:indexPath];
}



@end
