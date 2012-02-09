//
//  StatsViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 21/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "StatsViewController.h"
#import "YasoundDataProvider.h"
#import "DateAdditions.h"

#define SECTION_STATS 0
#define ROW_STATS_LISTENERS 0
//#define ROW_STATS_LIKES 1


//#define SECTION_WEEKCHART 1
//#define ROW_WEEKCHART_CONTROL 0
//#define ROW_WEEKCHART_CHART 1

#define SECTION_MONTHCHART 1
#define ROW_MONTHCHART_CONTROL 0
#define ROW_MONTHCHART_CHART 1

#define SECTION_LEADERBOARD 2
#define ROW_LEADERBOARD_CONTROL 0


#define GRAPH_X 5
#define GRAPH_Y 5
#define GRAPH_WIDTH 290
#define GRAPH_HEIGHT 180


#define RADIO_LISTENING_STAT_NB_DAYS 30


@implementation StatsViewController


//@synthesize weekGraphView;
//@synthesize monthGraphView;



- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
//        weekGraphView = [[ChartView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) minimalDisplay:NO];

        _monthGraphView = [[ChartView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) minimalDisplay:NO];
        
        _monthGraphView.plotColor = RGB(235,200,50);
        _monthGraphView.fillColor = RGBA(235,200,50,64);
      
      _leaderboard = nil;
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

    _titleLabel.text = NSLocalizedString(@"StatsView_title", nil);
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
    
    _btnNextWeek.enabled = NO;
    _btnNextMonth.enabled = NO;
    
    // simplify the process for now
    [_btnNextWeek removeFromSuperview];
    [_btnNextMonth removeFromSuperview];
    [_btnPreviousWeek removeFromSuperview];
    [_btnPreviousMonth removeFromSuperview];
    
    _cellMonthSelectorLabel.text = NSLocalizedString(@"StatsView_monthselector_label", nil);
  _cellLeaderBoardSelectorLabel.text = NSLocalizedString(@"StatsView_leaderboardselector_label", nil);
    
  [[YasoundDataProvider main] monthListeningStatsWithTarget:self action:@selector(receivedMonthStats:withInfo:)];
  [[YasoundDataProvider main] leaderboardWithTarget:self action:@selector(receivedLeaderBoard:withInfo:)];
  
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


- (void)receivedMonthStats:(NSArray*)stats withInfo:(NSDictionary*)info
{
  if (!stats || stats.count == 0)
    return;
  
  NSMutableArray* dates = [[NSMutableArray alloc] init];
  NSMutableArray* connections = [[NSMutableArray alloc] init];
  for (RadioListeningStat* stat in stats) 
  {
    [dates addObject:stat.date];
    [connections addObject:stat.connections];
  }
  
  NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  
  int nbStatsRequired = RADIO_LISTENING_STAT_NB_DAYS;
  
  while (dates.count < nbStatsRequired) 
  {
    NSDate* firstDate = [dates objectAtIndex:0];
    NSDateComponents* offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:-1]; // the day before
    NSDate* d = [gregorian dateByAddingComponents:offsetComponents toDate:firstDate options:0];
    [offsetComponents release];
    
    [dates insertObject:d atIndex:0];
    [connections insertObject:[NSNumber numberWithInt:0] atIndex:0];
  }
  
  [gregorian release];
  
  
  _monthGraphView.dates = dates;
  _monthGraphView.values = connections;
  [_monthGraphView reloadData];
}


- (void)receivedLeaderBoard:(NSArray*)entries withInfo:(NSDictionary*)info
{
  if (!entries || entries.count == 0)
    return;
  
  NSLog(@"%d entries in leaderboard", entries.count);
  for (LeaderBoardEntry* entry in entries)
  {
    NSLog(@"%@ - %@: %@ favorites %@", entry.leaderboard_rank, entry.name, entry.favorites, [entry isUserRadio] ? @"(user's radio)" : @"");
  }
  
  _leaderboard = entries;
  [_tableView reloadData];
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
    return 3;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
  if (section == SECTION_STATS)
    return 1;
  else if (section == SECTION_MONTHCHART)
    return 2;
  else if (section == SECTION_LEADERBOARD)
  {
    if (!_leaderboard)
        return 0;
    return _leaderboard.count + 1;
  }
  return 0;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if ((indexPath.section == SECTION_MONTHCHART) && (indexPath.row == ROW_MONTHCHART_CHART))
        return GRAPH_HEIGHT;

    return 44;
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowSingle.png"]];
    cell.backgroundView = view;
    [view release];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
  if ((indexPath.section == SECTION_MONTHCHART) && (indexPath.row == ROW_MONTHCHART_CONTROL))
    return _cellMonthSelector;
  if ((indexPath.section == SECTION_LEADERBOARD) && (indexPath.row == ROW_LEADERBOARD_CONTROL))
    return _cellLeaderBoardSelector;
  
  
  
  static NSString* CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  if (cell == nil) 
  {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
  }
  
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  cell.textLabel.textColor = [UIColor blackColor];
  
  if ((indexPath.section == SECTION_STATS) && (indexPath.row == ROW_STATS_LISTENERS))
  {      
    NSNumber* listeners = [YasoundDataProvider main].radio.nb_current_users;
    cell.textLabel.text = NSLocalizedString(@"StatsView_listeners_label", nil);
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", listeners];
    [cell.imageView setImage:[UIImage imageNamed:@"iconStatsListeners.png"]];
  }
  
  else if ((indexPath.section == SECTION_MONTHCHART) && (indexPath.row == ROW_MONTHCHART_CHART))
  {
    CGRect frame = CGRectMake(GRAPH_X, GRAPH_Y, GRAPH_WIDTH, GRAPH_HEIGHT - GRAPH_Y - 2);
    _monthGraphBoundingBox = [[UIView alloc] initWithFrame:frame];
    [cell.contentView addSubview:_monthGraphBoundingBox];
    
    frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _monthGraphView.frame = frame;
    [_monthGraphBoundingBox addSubview:_monthGraphView];
    _monthGraphView.clipsToBounds = YES;    
  }
  else if ((indexPath.section == SECTION_LEADERBOARD) && (indexPath.row > ROW_LEADERBOARD_CONTROL))
  {
    assert(indexPath.row > 0);
    NSUInteger entryIndex = indexPath.row - 1;
    LeaderBoardEntry* entry = [_leaderboard objectAtIndex:entryIndex];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", entry.leaderboard_rank, entry.name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", entry.favorites, @"favoris"];
    
    if ([entry isUserRadio])
      cell.textLabel.textColor = [UIColor redColor];
    
    [cell.imageView setImage:nil];
  }
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    
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



- (IBAction)onPreviousWeek:(id)sender
{

}

- (IBAction)onNextWeek:(id)sender
{
    
}


- (IBAction)onPreviousMonth:(id)sender
{
    
}


- (IBAction)onNextMonth:(id)sender
{
    
}


@end


