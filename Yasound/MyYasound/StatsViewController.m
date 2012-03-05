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
#import "BundleFileManager.h"
#import "Theme.h"


#define SECTION_STATS 0
#define ROW_STATS_LISTENERS 0
//#define ROW_STATS_LIKES 1


//#define SECTION_WEEKCHART 1
//#define ROW_WEEKCHART_CONTROL 0
//#define ROW_WEEKCHART_CHART 1

#define SECTION_MONTHCHART 1
//#define ROW_MONTHCHART_CONTROL 0
#define ROW_MONTHCHART_CHART 0

#define SECTION_LEADERBOARD 2
//#define ROW_LEADERBOARD_CONTROL 0


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
        
        _monthGraphView.plotColor = RGB(200,200,200);
        _monthGraphView.fillColor = RGBA(196,246,254,96);
      
      _listenersLabel = nil;
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
    
//    _btnNextWeek.enabled = NO;
//    _btnNextMonth.enabled = NO;
    
    // simplify the process for now
//    [_btnNextWeek removeFromSuperview];
//    [_btnNextMonth removeFromSuperview];
//    [_btnPreviousWeek removeFromSuperview];
//    [_btnPreviousMonth removeFromSuperview];
    
//    _cellMonthSelectorLabel.text = NSLocalizedString(@"StatsView_monthselector_label", nil);
//  _cellLeaderBoardSelectorLabel.text = NSLocalizedString(@"StatsView_leaderboardselector_label", nil);
    
  [[YasoundDataProvider main] monthListeningStatsWithTarget:self action:@selector(receivedMonthStats:withInfo:)];
  [[YasoundDataProvider main] leaderboardWithTarget:self action:@selector(receivedLeaderBoard:withInfo:)];
  [[YasoundDataProvider main] userRadioWithTarget:self action:@selector(receivedUserRadio:withInfo:)];
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

- (void)receivedUserRadio:(Radio*)r withInfo:(NSDictionary*)info
{
  if (!r)
    return;
  if (_listenersLabel)
  {
    NSNumber* listeners = r.nb_current_users;
    _listenersLabel.text = [NSString stringWithFormat:@"%@", listeners];
  }
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
    NSLog(@"%@ - %@: %@ favorites %@", entry.leaderboard_rank, entry.name, entry.leaderboard_favorites, [entry isUserRadio] ? @"(user's radio)" : @"");
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
    return 1;
  else if (section == SECTION_LEADERBOARD)
  {
    if (!_leaderboard)
        return 0;
    return _leaderboard.count;
  }
  return 0;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if ((indexPath.section == SECTION_MONTHCHART) && (indexPath.row == ROW_MONTHCHART_CHART))
        return GRAPH_HEIGHT;

    return 44;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 22;
}





- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString* title = nil;
    
    if (section == 0)
        return nil;
    
    if (section == SECTION_MONTHCHART)
        title = NSLocalizedString(@"StatsView_monthselector_label", nil);
    
    else if (section == SECTION_LEADERBOARD)
        title = NSLocalizedString(@"StatsView_leaderboardselector_label", nil);
    
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MenuSection" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    
    UIImage* image = [sheet image];
    CGFloat height = image.size.height;
    UIImageView* view = [[UIImageView alloc] initWithImage:image];
    view.frame = CGRectMake(0, 0, tableView.bounds.size.width, height);
    
    sheet = [[Theme theme] stylesheetForKey:@"MenuSectionTitle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = title;
    [view addSubview:label];
    
    return view;
}




- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ((indexPath.section == SECTION_MONTHCHART) && (indexPath.row == ROW_MONTHCHART_CHART))
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ChartBackground.png"]];
        cell.backgroundView = view;
        [view release];
        return;
    }
    
    
    NSInteger nbRows;
    if (indexPath.section == SECTION_STATS)
    {
        nbRows = 1;
    }
    else if (indexPath.section == SECTION_LEADERBOARD) 
    {
        nbRows = [_leaderboard count];
    }
    
    
    LeaderBoardEntry* entry = [_leaderboard objectAtIndex:indexPath.row];
    BOOL isUserRadio = [entry isUserRadio];

    if (nbRows == 1)
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowSingle.png"]];
        cell.backgroundView = view;
        [view release];
    }
    else if (indexPath.row == 0)
    {
        UIImageView* view = nil;
        if (isUserRadio)
            view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowGoldFirst.png"]];
        else
            view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowFirst.png"]];
        cell.backgroundView = view;
        [view release];
    }
    else if (indexPath.row == (nbRows -1))
    {
        UIImageView* view = nil;
        if (isUserRadio)
            view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowGoldLast.png"]];
        else
            view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowLast.png"]];
        cell.backgroundView = view;
        [view release];
    }
    else
    {
        UIImageView* view = nil;
        if (isUserRadio)
            view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowGoldInter.png"]];
        else
            view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowInter.png"]];
        cell.backgroundView = view;
        [view release];
    }
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
//  if ((indexPath.section == SECTION_MONTHCHART) && (indexPath.row == ROW_MONTHCHART_CONTROL))
//    return _cellMonthSelector;
//  if ((indexPath.section == SECTION_LEADERBOARD) && (indexPath.row == ROW_LEADERBOARD_CONTROL))
//    return _cellLeaderBoardSelector;
  
    UITableViewCell* cell = nil;
    
    if ((indexPath.section == SECTION_STATS) && (indexPath.row == ROW_STATS_LISTENERS))
    {      
        static NSString* CellIdentifier = @"Cell";

        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        if (cell == nil) 
        {
          cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        }

        NSNumber* listeners = [YasoundDataProvider main].radio.nb_current_users;
        cell.textLabel.text = NSLocalizedString(@"StatsView_listeners_label", nil);

      _listenersLabel = cell.detailTextLabel;
      _listenersLabel.text = [NSString stringWithFormat:@"%@", listeners];
      _listenersLabel.textColor = [UIColor colorWithRed:1 green:174.f/255.f blue:0 alpha:1];

        [cell.imageView setImage:[UIImage imageNamed:@"iconSubscribers.png"]];
      
    }
  
    else if ((indexPath.section == SECTION_MONTHCHART) && (indexPath.row == ROW_MONTHCHART_CHART))
    {
        static NSString* CellIdentifier = @"CellChart";

        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        if (cell == nil) 
        {
          cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        }


        CGRect frame = CGRectMake(GRAPH_X, GRAPH_Y, GRAPH_WIDTH, GRAPH_HEIGHT - GRAPH_Y - 2);
        _monthGraphBoundingBox = [[UIView alloc] initWithFrame:frame];
        [cell.contentView addSubview:_monthGraphBoundingBox];

        frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _monthGraphView.frame = frame;
        [_monthGraphBoundingBox addSubview:_monthGraphView];
        _monthGraphView.clipsToBounds = YES;    
    }

    
    else if (indexPath.section == SECTION_LEADERBOARD)
    {
        static NSString* CellIdentifier = @"CellLeaderboard";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) 
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        

        
        LeaderBoardEntry* entry = [_leaderboard objectAtIndex:indexPath.row];

        BundleStylesheet* sheet = nil;
        
        
        // radio rank + name
        sheet = [[Theme theme] stylesheetForKey:@"StatsView_LeaderBoard_Name" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UILabel* label = [[sheet makeLabel] autorelease];
        label.text = [NSString stringWithFormat:@"%@ - %@",  entry.leaderboard_rank, entry.name];
        [cell.contentView addSubview:label];

        // favorites
        sheet = [[Theme theme] stylesheetForKey:@"StatsView_LeaderBoard_Favorites" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        label = [[sheet makeLabel] autorelease];
        label.text = [NSString stringWithFormat:@"%@", entry.leaderboard_favorites];
        [cell.contentView addSubview:label];

        // favorites icon
        sheet = [[Theme theme] stylesheetForKey:@"StatsView_LeaderBoard_FavoritesIcon" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIImageView* imageView = [[sheet makeImage] autorelease];
        [cell.contentView addSubview:imageView];
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:160.f/255.f green:182.f/255.f blue:222.f/255.f alpha:1];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];

    
    
//    NSLog(@"cell nil : section %d  row %d", indexPath.section, indexPath.row);
    
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


