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


#define NB_TOKENS 4


@interface MyRadiosViewController ()

@end

@implementation MyRadiosViewController

static NSString* CellIdentifier = @"MyRadiosTableViewCell";

@synthesize cellLoader;
@synthesize radios;
@synthesize tableview;
@synthesize editing;
@synthesize radioToBroadcast;

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
    
    [[YasoundDataProvider main] radiosForUser:[YasoundDataProvider main].user withTarget:self action:@selector(radiosReceived:success:)];
}


- (void)radiosReceived:(ASIHTTPRequest*)req success:(BOOL)success
{
    [ActivityAlertView close];
    
    if (!success)
    {
        DLog(@"MyRadiosViewController::radiosReceived failed");
        assert(0);
        return;
    }
    
    [self.editing removeAllObjects];
    
    Container* container = [req responseObjectsWithClass:[Radio class]];
    self.radios = container.objects;
    
    for (Radio* radio in self.radios)
    {
        [self.editing setObject:[NSNumber numberWithBool:NO] forKey:radio.id];
    }
    
    
    [self.tableview reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableview reloadData];
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
    [[YasoundDataProvider main] radiosForUser:[YasoundDataProvider main].user withTarget:self action:@selector(radiosReceived:success:)];
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
        assert(nb);
        BOOL editing = [nb boolValue];


        cell.alpha = 0;

        [cell updateWithRadio:radio target:self editing:editing];
        
//        if (_tokens < NB_TOKENS) {
//            _tokens++;

//        if (_firstTime)
//            cell.alpha = 0;
//            [UIView beginAnimations:nil context:NULL];
//            [UIView setAnimationDelay:_tokens * 0.2];
//            [UIView setAnimationDelay:0.33];
//            cell.alpha = 1;
//            [UIView commitAnimations];
//            
//        }
        
        return cell;
    }
    
    if (indexPath.section == 1)
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellCreateIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellCreateIdentifier];

            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            //LBDEBUG TEMPORARLY
//            BOOL perm_geo_create_radio = [[YasoundDataProvider main].user permission:PERM_GEOCREATERADIO];
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
        
//        if ((self.radios.count < 3) && (_tokens < NB_TOKENS)) {
//            _tokens++;
//            
//            cell.alpha = 0;
//            [UIView beginAnimations:nil context:NULL];
//            [UIView setAnimationDelay:_tokens * 0.2];
//            [UIView setAnimationDelay:0.33];
//            cell.alpha = 1;
//            [UIView commitAnimations];
//            
//        }

        
        return cell;
    }
    
    return nil;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */










#pragma mark - MyRadiosTableViewCellDelegate

- (void)myRadioRequestedPlay:(Radio*)radio
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:radio];
}

- (void)myRadioRequestedStats:(Radio*)radio
{
    StatsViewController* view = [[StatsViewController alloc] initWithNibName:@"StatsViewController" bundle:nil forRadio:radio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (void)myRadioRequestedSettings:(Radio*)radio
{
    SettingsViewController* view = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil forRadio:radio createMode:NO];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}


- (void)myRadioRequestedBroadcast:(Radio*)radio
{
    [ActivityAlertView showWithTitle:nil];
    self.radioToBroadcast = radio;
    [[YasoundDataProvider main] favoriteUsersForRadio:radio target:self action:@selector(onSubscribersReceived:withInfo:) withUserData:radio];
}




- (void)onSubscribersReceived:(NSArray*)subscribers withInfo:(NSDictionary*)info
{
    [ActivityAlertView close];
    
    Radio* radio = self.radioToBroadcast;
    self.radioToBroadcast = nil;
    
    MessageBroadcastModalViewController* view = [[MessageBroadcastModalViewController alloc] initWithNibName:@"MessageBroadcastModalViewController" bundle:nil forRadio:radio subscribers:subscribers target:self action:@selector(onModalReturned)];
    [self.navigationController presentModalViewController:view animated:YES];
    [view release];
}

- (void)onModalReturned
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}



- (void)myRadioRequestedProgramming:(Radio*)radio
{
    ProgrammingViewController* view = [[ProgrammingViewController alloc] initWithNibName:@"ProgrammingViewController" bundle:nil  forRadio:radio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}







#pragma mark - TopBarDelegate

//- (BOOL)topBarItemClicked:(TopBarItemId)itemId
//{
//}



- (void)onCreateButtonClicked:(id)sender
{
//    SettingsViewController* view = [[SettingsViewController alloc] createWithNibName:@"SettingsViewController" bundle:nil];
//    [self.navigationController pushViewController:view animated:YES];
//    [view release];
    
    CreateRadioViewController* view = [[CreateRadioViewController alloc] initWithNibName:@"CreateRadioViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}



@end
