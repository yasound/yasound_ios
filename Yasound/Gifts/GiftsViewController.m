//
//  GiftsViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "GiftsViewController.h"
#import "TopBar.h"
#import "AudioStreamManager.h"
#import "Gift.h"
#import "YasoundDataProvider.h"
#import "GiftCell.h"
#import "YasoundSessionManager.h"
#import "Service.h"

#define SECTION_COUNT 1
#define SECTION_GIFTS 0


@interface GiftsViewController (internal)

- (void)disableHdBar;
- (void)updateWithHdExpirationDate:(NSDate*)expirationDate;


@end

@implementation GiftsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        //
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"commonGradient.png"]];
    [self disableHdBar];
    
    if (![YasoundSessionManager main].registered)
    {
        assert(0);
        return;
    }
    User* user = [YasoundDataProvider main].user;
    if ([user permission:PERM_HD])
    {
        // ask for HD expiration date
        [[YasoundDataProvider main] servicesWithTarget:self action:@selector(onServicesReceived:success:)];
    }
    // ask for gifts
    [[YasoundDataProvider main] giftsWithTarget:self action:@selector(onGiftsReceived:success:)];
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



- (void)onGiftsReceived:(ASIHTTPRequest*)request success:(BOOL)succeeded
{
    if (!succeeded)
        return;
    
    self.gifts = [request responseObjectsWithClass:[Gift class]].objects;
    Gift* g = [self.gifts objectAtIndex:0];
    g.action_url_ios = @"yasound://navigation/programming";
    [self.tableView reloadData];
}

- (void)disableHdBar
{
    self.iconHd.image = [UIImage imageNamed:@"commonIconHDGrey.png"];
    self.switchHd.enabled = NO;
    self.switchHd.on = NO;
    
    NSString* timeLeft = [NSString stringWithFormat:@"0 %@", NSLocalizedString(@"day", nil)];
    NSString* hdLeft = [NSString stringWithFormat:NSLocalizedString(@"HdTimeLeft", nil), timeLeft];
    self.labelHd.text = hdLeft;
}

- (void)onServicesReceived:(ASIHTTPRequest*)req success:(BOOL)success
{
    Container* container = [req responseObjectsWithClass:[Service class]];
    for (Service* serv in container.objects)
    {
        if ([serv isHd])
        {
            [self updateWithHdExpirationDate:serv.expiration_date];
            break;
        }
    }
}

- (void)updateWithHdExpirationDate:(NSDate*)expirationDate
{
    NSTimeInterval interval = [expirationDate timeIntervalSinceNow];
    if (interval <= 0)
    {
        [self disableHdBar];
        return;
    }
    
    double secondsPerMinute = 60.0;
    double secondsPerHour = 60.0 * secondsPerMinute;
    double secondsPerDay = 24.0 * secondsPerHour;
    int days = floor(interval / secondsPerDay);
    interval -= (days * secondsPerDay);
    int hours = floor(interval / secondsPerHour);
    interval -= (hours * secondsPerHour);
    int minutes = floor(interval / secondsPerMinute);
    
    NSString* timeLeft;
    if (days > 0)
    {
        NSString* dayStr = NSLocalizedString(@"day", nil);
        NSString* daysStr = NSLocalizedString(@"days", nil);
        timeLeft = [NSString stringWithFormat:@"%d %@", days, days > 1 ? daysStr : dayStr];
    }
    else if (hours > 1)
    {
        NSString* hourStr = NSLocalizedString(@"hour", nil);
        NSString* hoursStr = NSLocalizedString(@"hours", nil);
        timeLeft = [NSString stringWithFormat:@"%d %@", hours, hours > 1 ? hoursStr : hourStr];
    }
    else if (hours == 1)
    {
        NSString* hourStr = NSLocalizedString(@"hour", nil);
        NSString* hoursStr = NSLocalizedString(@"hours", nil);
        NSString* minuteStr = NSLocalizedString(@"minute", nil);
        NSString* minutesStr = NSLocalizedString(@"minutes", nil);
        timeLeft = [NSString stringWithFormat:@"%d %@ %d %@", hours, hours > 1 ? hoursStr : hourStr, minutes, minutes > 1 ? minutesStr : minuteStr];
    }
    else
    {
        NSString* minuteStr = NSLocalizedString(@"minute", nil);
        NSString* minutesStr = NSLocalizedString(@"minutes", nil);
        timeLeft = [NSString stringWithFormat:@"%d %@", minutes, minutes > 1 ? minutesStr : minuteStr];
    }
    NSString* hdLeft = [NSString stringWithFormat:NSLocalizedString(@"HdTimeLeft", nil), timeLeft];
    
    self.labelHd.text = hdLeft;
    self.iconHd.image = [UIImage imageNamed:@"commonIconHDBlue.png"];

    BOOL error = NO;
    BOOL userWantsHd = [[UserSettings main] boolForKey:USKEYuserWantsHd error:&error];
    if (error)
        userWantsHd = YES;
    self.switchHd.on = userWantsHd;
    self.switchHd.enabled = YES;
}

- (IBAction)hdSwitchChanged:(id)sender
{
    [[UserSettings main] setBool:self.switchHd.on forKey:USKEYuserWantsHd];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_GIFTS)
        if (!self.gifts)
            return 0;
        return [self.gifts count];
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Gift* gift = [self.gifts objectAtIndex:indexPath.row];
    static NSString* cellIdentifier = @"GiftTableViewCell";
    
    if (indexPath.section == SECTION_GIFTS)
    {
        GiftCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            cell = [[[GiftCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
        }
        cell.gift = gift;
        return cell;
    }
    
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Gift* gift = [self.gifts objectAtIndex:indexPath.row];
    if (![gift canBeWon])
        return;
    [self.popover dismissPopoverAnimated:NO];
    [gift doAction];
}



@end
