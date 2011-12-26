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



@implementation RadioSelectionViewController


//LBDEBUG
static NSArray* gFakeUsers = nil;


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil type:(RadioSelectionType)type title:(NSString*)title tabIcon:(NSString*)tabIcon
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
      _type = type;
      
      UIImage* tabImage = [UIImage imageNamed:tabIcon];
      UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:title image:tabImage tag:0];
      self.tabBarItem = theItem;
      [theItem release];      

      _tableView.delegate = self;
      _tableView.dataSource = self;
      
      // LBDEBUG static init
      if (gFakeUsers == nil)
      {
        NSDictionary* resources = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Resources"];
        gFakeUsers = [resources objectForKey:@"fakeUsers"];
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];

  _topBarTitle.text = self.title;

  NSString* str;
  
  _currentStyle = @"style_all";
  _categoryTitle.text = [NSLocalizedString(_currentStyle, nil) uppercaseString];


  [[YasoundDataProvider main] radiosTarget:self action:@selector(receiveRadios:withInfo:)];
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










- (void)receiveRadios:(NSArray*)radios withInfo:(NSDictionary*)info
{
  NSError* error = [info valueForKey:@"error"];
  if (error)
  {
    NSLog(@"can't get radios: %@", error.domain);
    return;
  }
  
  _radios = radios;
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
  return [_radios count];
}





- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
  static NSString *cellIdentifier = @"RadioSelectionTableViewCell";
  
  if (!_radios)
    return nil;
  
  NSInteger rowIndex = indexPath.row;
  
  Radio* r = [_radios objectAtIndex:rowIndex];
  NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
  [data setValue:r.name forKey:@"title"];
  [data setValue:r.creator.username forKey:@"subtitle1"];
  [data setValue:r.genre forKey:@"subtitle2"];
  [data setValue:r.likes forKey:@"likes"];
  [data setValue:r.listeners forKey:@"listeners"];
  
  NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:r.picture];
  [data setValue:imageURL forKey:@"imageURL"];
  
  RadioSelectionTableViewCell* cell = [[RadioSelectionTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier rowIndex:rowIndex data:data];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RadioViewController* view = [[RadioViewController alloc] init];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:view animated:YES];
    [view release];  
}




#pragma mark - IBActions

- (IBAction)onStyleSelectorClicked:(id)sender
{
  StyleSelectorViewController* view = [[StyleSelectorViewController alloc] initWithNibName:@"StyleSelectorViewController" bundle:nil target:self];
//  self.navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
   self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
  [self.navigationController presentModalViewController:view animated:YES];
}


#pragma mark - StyleSelectorDelegate

- (void)didSelectStyle:(NSString*)style
{
  [self.navigationController dismissModalViewControllerAnimated:YES];
  
  _currentStyle = style;
  _categoryTitle.text = [NSLocalizedString(_currentStyle, nil) uppercaseString];
  
  [_tableView reloadData];
}

- (void)cancelSelectStyle
{
  [self.navigationController dismissModalViewControllerAnimated:YES];
}



@end
