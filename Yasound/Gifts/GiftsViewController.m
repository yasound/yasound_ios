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
#import "Theme.h"
#import "RootViewController.h"
#import "PromoCodeCell.h"
#import "AudioStreamer.h"

#define SECTION_COUNT 2
#define SECTION_GIFTS 1
#define SECTION_PROMO 0

#define NB_ROWS_PROMO 1



@interface GiftsViewController (internal)

- (void)resetWithUserRegistered:(BOOL)registered;

- (void)enableHdBar:(BOOL)enabled;
- (void)updateHdBarWithExpirationDate:(NSDate*)expirationDate;

- (void)reloadHdExpirationDate;
- (void)reloadGifts;

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
    
    BOOL registered = [YasoundSessionManager main].registered;
    if (registered)
    {
        // reload user to have permissions up to date
        [[YasoundDataProvider main] reloadUserWithUserData:nil withTarget:self action:@selector(onUserReloaded:info:)];
    }
    else
    {
        [self resetWithUserRegistered:NO];
    }
}

- (void) onUserReloaded:(User*)u info:(NSDictionary*)info
{
    [self resetWithUserRegistered:YES];
}

- (void)resetWithUserRegistered:(BOOL)registered
{
    BOOL hdPermission = NO;
    User* user = [YasoundDataProvider main].user;
    if (user)
        hdPermission = [user permission:PERM_HD];
    BOOL hdBarEnabled = registered && hdPermission;
    [self enableHdBar:hdBarEnabled];
    
    [self reloadHdExpirationDate];
    [self reloadGifts];
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

- (void)enableHdBar:(BOOL)enabled
{
    if (!enabled)
    {
        self.iconHd.image = [UIImage imageNamed:@"commonIconHDGrey.png"];
        self.switchHd.enabled = NO;
        self.switchHd.on = NO;
        
        NSString* timeLeft = [NSString stringWithFormat:@"0 %@", NSLocalizedString(@"day", nil)];
        NSString* hdLeft = [NSString stringWithFormat:NSLocalizedString(@"HdTimeLeft", nil), timeLeft];
        self.labelHd.text = hdLeft;
    }
    else
    {
        self.iconHd.image = [UIImage imageNamed:@"commonIconHDBlue.png"];
        
        BOOL error = NO;
        BOOL userWantsHd = [[UserSettings main] boolForKey:USKEYuserWantsHd error:&error];
        if (error)
            userWantsHd = YES;
        self.switchHd.on = userWantsHd;
        self.switchHd.enabled = YES;
        
        self.labelHd.text = @"?";
    }
}



- (void)reloadGifts
{
    // ask for gifts
    [[YasoundDataProvider main] giftsWithTarget:self action:@selector(onGiftsReceived:success:)];
}

- (void)onGiftsReceived:(ASIHTTPRequest*)request success:(BOOL)succeeded
{
    if (!succeeded)
        return;
    
    self.gifts = [request responseObjectsWithClass:[Gift class]].objects;
    [self.tableView reloadData];
}

- (void)reloadHdExpirationDate
{
    if (![YasoundSessionManager main].registered)
        return;
    
    // ask for services to get HD service expiration date
    [[YasoundDataProvider main] servicesWithTarget:self action:@selector(onServicesReceived:success:)];
}

- (void)onServicesReceived:(ASIHTTPRequest*)req success:(BOOL)success
{
    Container* container = [req responseObjectsWithClass:[Service class]];
    for (Service* serv in container.objects)
    {
        if ([serv isHd])
        {
            [self updateHdBarWithExpirationDate:serv.expiration_date];
            break;
        }
    }
}

- (void)updateHdBarWithExpirationDate:(NSDate*)expirationDate
{
    NSTimeInterval interval = [expirationDate timeIntervalSinceNow];
    if (interval <= 0)
    {
        [self enableHdBar:NO];
        return;
    }
    [self enableHdBar:YES];
    
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
}

- (IBAction)hdSwitchChanged:(id)sender
{
    [[UserSettings main] setBool:self.switchHd.on forKey:USKEYuserWantsHd];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_HD_CHANGED  object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUDIOSTREAM_RESET  object:nil];
}

#pragma mark - promoCodeDelegate

- (void)promoCodeEntered:(NSString*)promoCode
{
    [[YasoundDataProvider main] activatePromoCode:promoCode withTarget:self action:@selector(promoCodeActivated:success:)];
}

- (void)promoCodeActivated:(ASIFormDataRequest*)req success:(BOOL)success
{
    NSDictionary* dict = [req responseDict];
    NSNumber* ok  = [dict valueForKey:@"success"];
    if ([ok boolValue])
    {
        [self reloadHdExpirationDate];
        [[YasoundDataProvider main] reloadUserWithUserData:nil withTarget:nil action:nil]; // reload user to have permissions up to date
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_GIFTS)
    {
        if (!self.gifts)
            return 0;
        return [self.gifts count];
    }
    else if (section == SECTION_PROMO)
        return NB_ROWS_PROMO;
        
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* giftCellIdentifier = @"GiftTableViewCell";
    static NSString* promoCellIdentifier = @"PromoTableViewCell";
    
    if (indexPath.section == SECTION_GIFTS)
    {
        Gift* gift = [self.gifts objectAtIndex:indexPath.row];

        GiftCell* cell = [tableView dequeueReusableCellWithIdentifier:giftCellIdentifier];
        if (cell == nil)
        {
            cell = [[[GiftCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:giftCellIdentifier] autorelease];
        }
        cell.gift = gift;
        return cell;
    }
    else if (indexPath.section == SECTION_PROMO)
    {
        PromoCodeCell* cell = [tableView dequeueReusableCellWithIdentifier:promoCellIdentifier];
        if (cell == nil)
        {
            cell = [[PromoCodeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:promoCellIdentifier];
            cell.promoCodeDelegate = self;
        }
        [cell reset];
        return cell;
    }
    
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_GIFTS)
    {
        Gift* gift = [self.gifts objectAtIndex:indexPath.row];
        if (![gift canBeWon])
            return;
        [self.popover dismissPopoverAnimated:YES];
        [gift doAction];
    }
    else if (indexPath.section == SECTION_PROMO)
    {
        if (![YasoundSessionManager main].registered)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_LOGIN object:nil];
            [self.popover dismissPopoverAnimated:YES];
        }
    }
    
}



@end
