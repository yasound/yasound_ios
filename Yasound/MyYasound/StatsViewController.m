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
#define ROW_STATS_LIKES 1


#define SECTION_WEEKCHART 1
#define ROW_WEEKCHART_CONTROL 0
#define ROW_WEEKCHART_CHART 1

#define SECTION_MONTHCHART 2
#define ROW_MONTHCHART_CONTROL 0
#define ROW_MONTHCHART_CHART 1


#define GRAPH_X 5
#define GRAPH_Y 5
#define GRAPH_WIDTH 290
#define GRAPH_HEIGHT 180


#define RADIO_LISTENING_STAT_DELTA_HOURS 1


@implementation StatsViewController


@synthesize weekGraphView;
@synthesize monthGraphView;



- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        weekGraphView = [[ChartView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) minimalDisplay:NO];

        monthGraphView = [[ChartView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) minimalDisplay:NO];
        
        monthGraphView.plotColor = RGB(235,200,50);
        monthGraphView.fillColor = RGBA(235,200,50,64);

      _lastStat = nil;
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
    
    _cellWeekSelectorLabel.text = NSLocalizedString(@"StatsView_weekselector_label", nil);
    _cellMonthSelectorLabel.text = NSLocalizedString(@"StatsView_monthselector_label", nil);
  
  [[YasoundDataProvider main] weekListeningStatsWithTarget:self action:@selector(receivedWeekStats:withInfo:)];
  [[YasoundDataProvider main] monthListeningStatsWithTarget:self action:@selector(receivedMonthStats:withInfo:)];
  
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




- (void)receivedWeekStats:(NSArray*)stats withInfo:(NSDictionary*)info
{
  if (!stats || stats.count == 0)
    return;
  
  _lastStat = [stats objectAtIndex:stats.count - 1];
  if (_listenersLabel)
    _listenersLabel.text = [NSString stringWithFormat:@"%@", _lastStat.audience];
  if (_favoritesLabel)
    _favoritesLabel.text = [NSString stringWithFormat:@"%@", _lastStat.favorites];

  NSMutableArray* dates = [[NSMutableArray alloc] init];
  NSMutableArray* audiences = [[NSMutableArray alloc] init];
  for (RadioListeningStat* stat in stats) 
  {
    [dates addObject:stat.date];
    [audiences addObject:stat.audience];
  }
  
  NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  
  int nbStatsRequired = 7 * (24.0 / RADIO_LISTENING_STAT_DELTA_HOURS);
  
  while (dates.count < nbStatsRequired) 
  {
    NSDate* firstDate = [dates objectAtIndex:0];
    NSDateComponents* offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setHour:-1]; // the hour before
    NSDate* d = [gregorian dateByAddingComponents:offsetComponents toDate:firstDate options:0];
    [offsetComponents release];
    
    [dates insertObject:d atIndex:0];
    [audiences insertObject:[NSNumber numberWithInt:0] atIndex:0];
  }
  
  [gregorian release];
  
  weekGraphView.dates = dates;
  weekGraphView.values = audiences;
  [weekGraphView reloadData];
}


- (void)receivedMonthStats:(NSArray*)stats withInfo:(NSDictionary*)info
{
  if (!stats || stats.count == 0)
    return;
  
  _lastStat = [stats objectAtIndex:stats.count - 1];
  if (_listenersLabel)
    _listenersLabel.text = [NSString stringWithFormat:@"%@", _lastStat.audience];
  if (_favoritesLabel)
    _favoritesLabel.text = [NSString stringWithFormat:@"%@", _lastStat.favorites];
  
  NSMutableArray* dates = [[NSMutableArray alloc] init];
  NSMutableArray* audiences = [[NSMutableArray alloc] init];
  for (RadioListeningStat* stat in stats) 
  {
    [dates addObject:stat.date];
    [audiences addObject:stat.audience];
  }
  
  NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  
  int nbStatsRequired = 28 * (24.0 / RADIO_LISTENING_STAT_DELTA_HOURS); // at least 28 days
  
  while (dates.count < nbStatsRequired) 
  {
    NSDate* firstDate = [dates objectAtIndex:0];
    NSDateComponents* offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setHour:-1]; // the hour before
    NSDate* d = [gregorian dateByAddingComponents:offsetComponents toDate:firstDate options:0];
    [offsetComponents release];
    
    [dates insertObject:d atIndex:0];
    [audiences insertObject:[NSNumber numberWithInt:0] atIndex:0];
  }
  
  [gregorian release];
  
  
  monthGraphView.dates = dates;
  monthGraphView.values = audiences;
  [monthGraphView reloadData];
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
    return 2;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == SECTION_WEEKCHART) && (indexPath.row == ROW_WEEKCHART_CHART))
        return GRAPH_HEIGHT;
    
    if ((indexPath.section == SECTION_MONTHCHART) && (indexPath.row == ROW_MONTHCHART_CHART))
        return GRAPH_HEIGHT;

    return 44;
}



//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
//{
//    if (tableView == _settingsTableView)
//        [self willDisplayCellInSettingsTableView:cell forRowAtIndexPath:indexPath];
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ((indexPath.section == SECTION_WEEKCHART) && (indexPath.row == ROW_WEEKCHART_CONTROL))
        return _cellWeekSelector;
    if ((indexPath.section == SECTION_MONTHCHART) && (indexPath.row == ROW_MONTHCHART_CONTROL))
        return _cellMonthSelector;

    
    
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ((indexPath.section == SECTION_STATS) && (indexPath.row == ROW_STATS_LISTENERS))
    {
      NSString* audienceStr = @"-";
      if (_lastStat)
        audienceStr = [NSString stringWithFormat:@"%@", _lastStat.audience];
      
      cell.textLabel.text = NSLocalizedString(@"StatsView_listeners_label", nil);
      cell.detailTextLabel.text = audienceStr;
      _listenersLabel = cell.detailTextLabel;
      [cell.imageView setImage:[UIImage imageNamed:@"iconStatsListeners.png"]];
    }

    else if ((indexPath.section == SECTION_STATS) && (indexPath.row == ROW_STATS_LIKES))
    {
      NSString* favoritesStr = @"-";
      if (_lastStat)
        favoritesStr = [NSString stringWithFormat:@"%@", _lastStat.favorites];

      
        cell.textLabel.text = NSLocalizedString(@"StatsView_likes_label", nil);
        cell.detailTextLabel.text = favoritesStr;
      _favoritesLabel = cell.detailTextLabel;
        [cell.imageView setImage:[UIImage imageNamed:@"iconStatsLikes.png"]];
    }

    else if ((indexPath.section == SECTION_WEEKCHART) && (indexPath.row == ROW_WEEKCHART_CHART))
    {
        CGRect frame = CGRectMake(GRAPH_X, GRAPH_Y, GRAPH_WIDTH, GRAPH_HEIGHT - GRAPH_Y - 2);
        _weekGraphBoundingBox = [[UIView alloc] initWithFrame:frame];
        [cell.contentView addSubview:_weekGraphBoundingBox];
        
        frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        weekGraphView.frame = frame;
        [_weekGraphBoundingBox addSubview:weekGraphView];
        weekGraphView.clipsToBounds = YES;    
    }

    else if ((indexPath.section == SECTION_MONTHCHART) && (indexPath.row == ROW_MONTHCHART_CHART))
    {
        CGRect frame = CGRectMake(GRAPH_X, GRAPH_Y, GRAPH_WIDTH, GRAPH_HEIGHT - GRAPH_Y - 2);
        _monthGraphBoundingBox = [[UIView alloc] initWithFrame:frame];
        [cell.contentView addSubview:_monthGraphBoundingBox];
        
        frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        monthGraphView.frame = frame;
        [_monthGraphBoundingBox addSubview:monthGraphView];
        monthGraphView.clipsToBounds = YES;    
    }
    
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




#pragma mark - Properties


- (void)reloadData
{
    [_tableView reloadData];
    [weekGraphView reloadData];
    [monthGraphView reloadData];
}

@end


