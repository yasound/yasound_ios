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


#define SECTION_MONTHCHART 1
#define ROW_MONTHCHART_CHART 0

#define SECTION_LEADERBOARD 2


#define GRAPH_X 5
#define GRAPH_Y 5
#define GRAPH_WIDTH 290
#define GRAPH_HEIGHT 180


#define RADIO_LISTENING_STAT_NB_DAYS 30


@implementation StatsViewController

@synthesize leaderboard;
@synthesize radio;


- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil forRadio:(Radio*)radio
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
        self.radio = radio;
        _monthGraphView = [[ChartView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) minimalDisplay:NO];
        
        _monthGraphView.plotColor = RGB(200,200,200);
        _monthGraphView.fillColor = RGBA(196,246,254,96);
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

    [[YasoundDataProvider main] monthListeningStatsForRadio:self.radio withTarget:self action:@selector(receivedMonthStats:withInfo:)];
    [[YasoundDataProvider main] leaderboardForRadio:self.radio withTarget:self action:@selector(receivedLeaderBoard:success:)];
    [[YasoundDataProvider main] radioWithId:self.radio.id target:self action:@selector(receivedRadio:withInfo:)];
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

- (void)receivedRadio:(Radio*)r withInfo:(NSDictionary*)info
{
  if (!r)
    return;
    
    UITableViewCell* cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_STATS_LISTENERS inSection:SECTION_STATS]];
    NSNumber* listeners = r.nb_current_users;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", listeners];
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


- (void)receivedLeaderBoard:(ASIHTTPRequest*)req success:(BOOL)success
{
    Container* leaderboardContainer = [req responseObjectsWithClass:[LeaderBoardEntry class]];
    if (!leaderboardContainer || leaderboardContainer.objects == nil || leaderboardContainer.objects.count == 0)
        return;
    
    self.leaderboard = leaderboardContainer.objects;
    [_tableView reloadData];
}





#pragma mark - TableView Source and Delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_STATS)
        return nil;

    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 26)];
    view.backgroundColor = [UIColor clearColor];
    
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.viewForHeader" retainStylesheet:YES overwriteStylesheet:YES error:nil];
    UILabel* label = [sheet makeLabel];
    
    if (section == SECTION_MONTHCHART)
        label.text = NSLocalizedString(@"Stats.section.month", nil);
    
    else if (section == SECTION_LEADERBOARD)
        label.text = NSLocalizedString(@"Stats.section.leaderboard", nil);
    
    [view addSubview:label];
    
    return view;
}



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
    if (!self.leaderboard)
        return 0;
    return self.leaderboard.count;
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
    return 26;
}




- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ((indexPath.section == SECTION_STATS) && (indexPath.row == ROW_STATS_LISTENERS))
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"statsBtnListeners.png"]];
        cell.backgroundView = view;
        [view release];
        return;        
    }
    
    if ((indexPath.section == SECTION_MONTHCHART) && (indexPath.row == ROW_MONTHCHART_CHART))
    {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"statsChartBackground.png"]];
        cell.backgroundView = view;
        [view release];
        return;
    }
    
    
    NSInteger nbRows = [self.leaderboard count];
    
    LeaderBoardEntry* entry = [self.leaderboard objectAtIndex:indexPath.row];
    BOOL isUserRadio = [entry isUserRadio];

    if (nbRows == 1)
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.willDisplayCell.rowSingle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        cell.backgroundView = [sheet makeImage];
    }
    else if (indexPath.row == 0)
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.willDisplayCell.rowFirst" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        cell.backgroundView = [sheet makeImage];
    }
    else if (indexPath.row == (nbRows -1))
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.willDisplayCell.rowLast" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        cell.backgroundView = [sheet makeImage];
    }
    else
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.willDisplayCell.rowInter" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        cell.backgroundView = [sheet makeImage];
    }

    
}



#define TITLE_MAX_LENGTH 22

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
  
    UITableViewCell* cell = nil;
    
    if ((indexPath.section == SECTION_STATS) && (indexPath.row == ROW_STATS_LISTENERS))
    {      
        static NSString* CellIdentifier = @"Cell";

        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        if (cell == nil) 
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            cell.textLabel.textColor = [UIColor whiteColor];
            [cell.imageView setImage:[UIImage imageNamed:@"statsIconHeadphones.png"]];

            cell.detailTextLabel.textColor = [UIColor colorWithRed:162.f/255.f green:162.f/255.f blue:162.f/255.f alpha:1];
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        }

        NSNumber* listeners = [YasoundDataProvider main].radio.nb_current_users;
        cell.textLabel.text = NSLocalizedString(@"StatsView_listeners_label", nil);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", listeners];

      
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
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.detailTextLabel.textColor = [UIColor darkGrayColor];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        }
        

        
        LeaderBoardEntry* entry = [self.leaderboard objectAtIndex:indexPath.row];

        BundleStylesheet* sheet = nil;
        
        NSString* title = [NSString stringWithFormat:@"%@ - %@",  entry.leaderboard_rank, entry.name];
        
        if (title.length > TITLE_MAX_LENGTH) {
            title = [title substringToIndex:TITLE_MAX_LENGTH];
            title = [title stringByAppendingString:@"..."];
        }
        
        
        cell.textLabel.text = title;

        NSString* infos = [NSString stringWithFormat:@"%@", entry.leaderboard_favorites];
        NSLog(@"infos '%@'", infos);
        
        cell.detailTextLabel.text = infos;
        
        NSLog(@"NB favorites '%@'", entry.leaderboard_favorites);
        NSLog(@"cell '%@'", cell.detailTextLabel.text);

        // favorites icon
        sheet = [[Theme theme] stylesheetForKey:@"Stats.iconFavorites" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        cell.accessoryView = [sheet makeImage];
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


@end


