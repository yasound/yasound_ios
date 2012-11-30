//
//  MyRadiosViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "MyRadiosViewController.h"
#import "TopBar.h"
#import "AudioStreamManager.h"
#import "YasoundDataProvider.h"
#import "MyRadiosTableViewCell.h"
#import "RootViewController.h"
#import "StatsViewController.h"
#import "SettingsViewController.h"
#import "Theme.h"
#import "CreateRadioViewController.h"
#import "ActivityAlertView.h"
#import "ProgrammingViewController.h"
#import "MessageBroadcastModalViewController.h"
#import "YasoundAppDelegate.h"
#import "YasoundDataCacheImage.h"

#define NB_TOKENS 4


@interface MyRadiosViewController ()

@end

@implementation MyRadiosViewController

static NSString* CellIdentifier = @"MyRadiosTableViewCell";

@synthesize cellLoader;
@synthesize radios;
@synthesize tableview;
@synthesize editing;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
        self.cellLoader = [UINib nibWithNibName:CellIdentifier bundle:[NSBundle mainBundle]];
        self.editing = [[NSMutableDictionary alloc] init];
        _tokens = 0;
        _firstTime = YES;
    }
    return self;
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.cellLoader release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifMyRadioDeleted:) name:NOTIF_MYRADIO_DELETED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifMyRadioEdited:) name:NOTIF_MYRADIO_EDIT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifMyRadioUnedited:) name:NOTIF_MYRADIO_UNEDIT object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifRefreshGui:) name:NOTIF_REFRESH_GUI object:nil];
    
    [[YasoundDataProvider main] radiosForUser:[YasoundDataProvider main].user withCompletionBlock:^(int status, NSString* response, NSError* error){        
        [self radiosRequestReturnedWithStatus:status response:response error:error];
    }];
}

- (void)radiosRequestReturnedWithStatus:(int)status response:(NSString*)response error:(NSError*)error
{
    BOOL success = YES;
    if (error)
    {
        DLog(@"radios for user error: %d - %@", error.code, error. domain);
        success = NO;
    }
    if (status != 200)
    {
        DLog(@"radios for user error: response status %d", status);
        success = NO;
    }
    Container* radioContainer = [response jsonToContainer:[Radio class]];
    if (!radioContainer || !radioContainer.objects)
    {
        DLog(@"radios for user error: cannot parse response %@", response);
        success = NO;
    }
    [ActivityAlertView close];
    if (!success)
        return;
    
    [self.editing removeAllObjects];
    
    self.radios = radioContainer.objects;
    for (Radio* radio in self.radios)
    {
        [self.editing setObject:[NSNumber numberWithBool:NO] forKey:radio.id];
    }
    [self.tableview reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.tableview reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
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


- (void)onNotifMyRadioDeleted:(NSNotification*)notification
{
    // refresh data
    [[YasoundDataProvider main] radiosForUser:[YasoundDataProvider main].user withCompletionBlock:^(int status, NSString* response, NSError* error){
        [self radiosRequestReturnedWithStatus:status response:response error:error];
    }];
}

- (void)onNotifMyRadioEdited:(NSNotification*)notification
{
    Radio* radio = notification.object;
    [self.editing setObject:[NSNumber numberWithBool:YES] forKey:radio.id];
}

- (void)onNotifMyRadioUnedited:(NSNotification*)notification
{
    Radio* radio = notification.object;
    [self.editing setObject:[NSNumber numberWithBool:NO] forKey:radio.id];
}

- (void)onNotifRefreshGui:(NSNotification*)notification
{
    [self.tableview reloadData];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ((section == 0) && (self.radios == nil))
        return 0;
    
    if (section == 0)
        return self.radios.count;
    
    return 1;
}

#define ROW_CREATE_HEIGHT 88

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, ROW_CREATE_HEIGHT)];
    view.backgroundColor = [UIColor clearColor];
    cell.backgroundView = view;
    [view release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return 167.f;
    
    return ROW_CREATE_HEIGHT;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellCreateIdentifier = @"CellCreateRadio";
    
    if (indexPath.section == 0)
    {
        Radio* radio = [self.radios objectAtIndex:indexPath.row];
        
        MyRadiosTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) 
        {
            NSLog(@"CREATE RADIO");
            NSArray *topLevelItems = [self.cellLoader instantiateWithOwner:self options:nil];
            cell = [topLevelItems objectAtIndex:0];
            cell.delegate = self;
        }
 
        NSNumber* nb = [self.editing objectForKey:radio.id];
        BOOL editing = NO;
        if (!nb)
            editing = [nb boolValue];


        cell.alpha = 0;

        [cell updateWithRadio:radio target:self editing:editing];
        
        return cell;
    }
    
    if (indexPath.section == 1)
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellCreateIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellCreateIdentifier];

            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            BOOL perm_geo_create_radio = YES;
            if (perm_geo_create_radio)
            {
                BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.BigButtonBlue.button" retainStylesheet:YES overwriteStylesheet:NO error:nil];
                UIButton* button = [sheet makeButton];
                CGFloat height = ROW_CREATE_HEIGHT;
                CGRect rect = CGRectMake(cell.frame.size.width/2.f - button.frame.size.width/2.f, height/2.f - button.frame.size.height/2.f, button.frame.size.width, button.frame.size.height);
                button.frame = rect;
                [button addTarget:self action:@selector(onCreateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:button];
                
                sheet = [[Theme theme] stylesheetForKey:@"TableView.BigButtonBlue.label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
                UILabel* label = [sheet makeLabel];
                label.text = NSLocalizedString(@"MyRadios.create", nil);
                [button addSubview:label];
                
                // handle create permission
                BOOL perm_create_radio = [[YasoundDataProvider main].user permission:PERM_CREATERADIO];
                button.enabled = perm_create_radio;
            }
                
            else
            {
                BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MyRadios.geolocRestriction" retainStylesheet:YES overwriteStylesheet:NO error:nil];
                UILabel* label = [sheet makeLabel];
                label.text = NSLocalizedString(@"MyRadios.geolocRestriction", nil);
                label.numberOfLines = 2;
                [cell addSubview:label];
            }
            
        }
        
        return cell;
    }
    
    return nil;
}






#pragma mark - MyRadiosTableViewCellDelegate

- (void)myRadioRequestedPlay:(Radio*)radio
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:radio];
}

- (void)myRadioRequestedStats:(Radio*)radio
{
    StatsViewController* view = [[StatsViewController alloc] initWithNibName:@"StatsViewController" bundle:nil forRadio:radio];
    [APPDELEGATE.navigationController pushViewController:view animated:YES];
    [view release];
}

- (void)myRadioRequestedSettings:(Radio*)radio
{
    SettingsViewController* view = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil forRadio:radio createMode:NO];
    [APPDELEGATE.navigationController pushViewController:view animated:YES];
    [view release];
}


- (void)myRadioRequestedBroadcast:(Radio*)radio
{
    [ActivityAlertView showWithTitle:nil];
    
    [[YasoundDataProvider main] favoriteUsersForRadio:radio withCompletionBlock:^(int status, NSString* response, NSError* error){
        if (error)
        {
            DLog(@"radio favorite users error: %d - %@", error.code, error. domain);
            return;
        }
        if (status != 200)
        {
            DLog(@"radio favorite users error: response status %d", status);
            return;
        }
        Container* usersContainer = [response jsonToContainer:[User class]];
        if (usersContainer == nil)
        {
            DLog(@"radio favorite users error: cannot parse response %@", response);
            return;
        }
        if (usersContainer.objects == nil)
        {
            DLog(@"radio favorite users error: bad response %@", response);
            return;
        }
        
        [ActivityAlertView close];
        
        MessageBroadcastModalViewController* view = [[MessageBroadcastModalViewController alloc] initWithNibName:@"MessageBroadcastModalViewController" bundle:nil forRadio:radio subscribers:usersContainer.objects target:self action:@selector(onModalReturned)];
        [APPDELEGATE.navigationController presentModalViewController:view animated:YES];
        [view release];
    }];
}

- (void)onModalReturned
{
    [APPDELEGATE.navigationController dismissModalViewControllerAnimated:YES];
}



- (void)myRadioRequestedProgramming:(Radio*)radio
{
    ProgrammingViewController* view = [[ProgrammingViewController alloc] initWithNibName:@"ProgrammingViewController" bundle:nil  forRadio:radio];
    [APPDELEGATE.navigationController pushViewController:view animated:YES];
    [view release];
}







#pragma mark - TopBarDelegate



- (void)onCreateButtonClicked:(id)sender
{
    CreateRadioViewController* view = [[CreateRadioViewController alloc] initWithNibName:@"CreateRadioViewController" bundle:nil];
    [APPDELEGATE.navigationController pushViewController:view animated:YES];
    [view release];
}



@end
