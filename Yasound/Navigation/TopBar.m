//
//  TopBar.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 18/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "TopBar.h"
#import "Theme.h"
#import "AudioStreamManager.h"
#import "RootViewController.h"
#import "YasoundAppDelegate.h"
#import "NotificationCenterViewController.h"
#import "YasoundSessionManager.h"
#import "PurchaseViewController.h"
#import "AudioStreamManager.h"
#import "YasoundDataProvider.h"
#import "CustomSizedButtonView.h"
#import "GiftsViewController.h"
#import "CustomSizedButtonView.h"

#import "FPPopoverController.h"

@implementation TopBar

@synthesize delegate;
@synthesize customItems;
@synthesize itemHdButton;
@synthesize itemSearch;
@synthesize itemSearchButton;


#define INDEX_BACK 0
#define INDEX_HD 2
#define INDEX_NOTIFS 4
#define INDEX_SEARCH 6
#define INDEX_NOWPLAYING 8




- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


- (void)awakeFromNib
{
    self.backgroundColor = [UIColor blackColor];
    
    self.barStyle = UIBarStyleBlack;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifDidLogout:) name:NOTIF_DID_LOGOUT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifDidLogin:) name:NOTIF_DID_LOGIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifsChanged:) name:NOTIF_HANDLE_IOS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHdChanged:) name:NOTIF_HD_CHANGED object:nil];
    
    
    // set background
    if ([self respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)]) 
        [self setBackgroundImage:[UIImage imageNamed:@"topBarBkg.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    else 
        [self insertSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topBarBkg.png"]] autorelease] atIndex:0];
    
    [self update];
}



- (void)update
{
    BundleStylesheet* sheet = nil;
    UIButton* btn = nil;
    
    // back button
    CustomSizedButtonView* customView = [[CustomSizedButtonView alloc] initWithThemeRef:@"back" title:NSLocalizedString(@"Navigation.back", nil)];
    customView.target = self;
    customView.action = @selector(onBack:);
    UIBarButtonItem* itemBack = [[UIBarButtonItem alloc] initWithCustomView:customView];
    

    // hd
    sheet = [[Theme theme] stylesheetForKey:@"TopBar.itemHd" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.itemHdButton = [sheet makeButton];
    [self updateHd];
    self.itemHd = [[UIBarButtonItem alloc] initWithCustomView:self.itemHdButton];

    // search
    sheet = [[Theme theme] stylesheetForKey:@"TopBar.itemSearch" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.itemSearchButton = [sheet makeButton];
    [self.itemSearchButton addTarget:self action:@selector(onSearch:) forControlEvents:UIControlEventTouchUpInside];
    self.itemSearch = [[UIBarButtonItem alloc] initWithCustomView:self.itemSearchButton];

    //  "notif"  item
    sheet = [[Theme theme] stylesheetForKey:@"TopBar.itemNotif" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.itemNotifsButton = [sheet makeButton];
    if ([YasoundSessionManager main].registered)
    {
        [self.itemNotifsButton addTarget:self action:@selector(onNotif:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        self.itemNotifsButton.enabled = NO;
    }
    self.itemNotifs = [[UIBarButtonItem alloc] initWithCustomView:self.itemNotifsButton];
    
    // "now playing" item
    sheet = [[Theme theme] stylesheetForKey:@"TopBar.itemNowPlaying" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.itemNowPlayingButton = [sheet makeButton];
    [self.itemNowPlayingButton addTarget:self action:@selector(onNowPlaying:) forControlEvents:UIControlEventTouchUpInside];
    
    sheet = [[Theme theme] stylesheetForKey:@"TopBar.itemNowPlayingLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.itemNowPlayingLabel = [sheet makeLabel];
    self.itemNowPlayingLabel.text = NSLocalizedString(@"Navigation.nowPlaying", nil);
    self.itemNowPlayingLabel.adjustsFontSizeToFitWidth = YES;
    [self.itemNowPlayingButton addSubview:self.itemNowPlayingLabel];
    
    self.itemNowPlaying = [[UIBarButtonItem alloc] initWithCustomView:self.itemNowPlayingButton];

    [self updateNowPlaying];
    
    
    // flexible space
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.customItems = [NSMutableArray arrayWithObjects:itemBack, flexibleSpace, self.itemHd, flexibleSpace, self.itemNotifs, flexibleSpace, self.itemSearch, flexibleSpace, self.itemNowPlaying, nil];
    
    [self setItems:self.customItems];
    
    
    // check notifs
    [self updateNotifs];
    

}




- (void)updateNowPlaying {
    
    if ([AudioStreamManager main].currentRadio == nil) {
        [self.itemNowPlayingButton setEnabled:NO];
        self.itemNowPlayingLabel.alpha = 0.5;
    }
    else {
        [self.itemNowPlayingButton setEnabled:YES];
        self.itemNowPlayingLabel.alpha = 1;
    }
    
}










- (void)hideBackItem:(BOOL)hide
{
    if (hide)
    {
        UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [self.customItems replaceObjectAtIndex:INDEX_BACK withObject:flexibleSpace];
        [self setItems:self.customItems];
    }
}

- (void)hideNowPlaying {
    
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self.customItems replaceObjectAtIndex:INDEX_NOWPLAYING withObject:flexibleSpace];
    [self setItems:self.customItems];
}



- (void)showSettingsItem:(BOOL)enabled
{
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TopBar.itemSettings" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.itemSettingsButton = [sheet makeButton];

    if (enabled)
    {
        [self.itemSettingsButton addTarget:self action:@selector(onSettings:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        self.itemSettingsButton.enabled = NO;
    }

    self.itemSettings = [[UIBarButtonItem alloc] initWithCustomView:self.itemSettingsButton];
    
    [self.customItems replaceObjectAtIndex:INDEX_NOWPLAYING withObject:self.itemSettings];
    [self setItems:self.customItems];
    
    // check settings button
    [self updateSettings:enabled];

}


- (void)showTrashItem
{
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TopBar.itemTrash" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIButton* btn = [sheet makeButton];
    
    [btn addTarget:self action:@selector(onTrash:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    [self.customItems replaceObjectAtIndex:INDEX_NOWPLAYING withObject:item];
    [self setItems:self.customItems];
}


- (void)showMenuItem
{
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TopBar.itemMenu" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIButton* btn = [sheet makeButton];
    
    [btn addTarget:self action:@selector(onMenu:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    [self.customItems replaceObjectAtIndex:INDEX_BACK withObject:item];
    [self setItems:self.customItems];
    
    [self updateNowPlaying];
}





- (void)showEditItem
{
    CustomSizedButtonView* editButton = [[CustomSizedButtonView alloc] initWithThemeRef:@"darkGray" title:NSLocalizedString(@"Navigation.edit", nil)];

    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    editButton.target = self;
    editButton.action = @selector(onEdit:);
    
    [self.customItems replaceObjectAtIndex:INDEX_NOWPLAYING withObject:item];
    [self setItems:self.customItems];
    
}











- (void)updateHd
{
    self.itemHd.enabled = YES;
    self.itemHdButton.enabled = YES;
    [self.itemHdButton addTarget:self action:@selector(onHd:) forControlEvents:UIControlEventTouchUpInside];
    
    BOOL activated = [[UserSettings main] boolForKey:USKEYuserWantsHd error:nil];
    activated &= [[YasoundDataProvider main].user permission:PERM_HD];
    
    if (activated)
        self.itemHdButton.selected = YES;
    else
        self.itemHdButton.selected = NO;
}





- (void)updateNotifs
{
    if (![YasoundSessionManager main].registered)
    {
        self.itemNotifs.enabled = NO;
        self.itemNotifsButton.enabled = NO;
        self.itemNotifsButton.selected = NO;
        
        if (self.itemNotifsLabel) {
            [self.itemNotifsLabel removeFromSuperview];
            [self.itemNotifsLabel release];
            self.itemNotifsLabel = nil;
        }
        
        [self.itemNotifsButton removeTarget:self action:@selector(onNotif:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        self.itemNotifs.enabled = YES;
        self.itemNotifsButton.enabled = YES;
        [self.itemNotifsButton addTarget:self action:@selector(onNotif:) forControlEvents:UIControlEventTouchUpInside];

        // request number of unread notifs        
        [[YasoundDataProvider main] unreadNotificationCountWithCompletionBlock:^(int status, NSString* response, NSError* error){
            BOOL success = (error == nil) && (status == 200) && (response != nil);
            if (!success)
            {
                DLog(@"get user notifications FAILED");
                return;
            }
            
            if (self.itemNotifsLabel) {
                [self.itemNotifsLabel removeFromSuperview];
                [self.itemNotifsLabel release];
                self.itemNotifsLabel = nil;
                
            }
            
            NSDictionary* responseDict = [response jsonToDictionary];
            NSNumber* unreadCountNumber = [responseDict valueForKey:@"unread_count"];
            int unreadCount = [unreadCountNumber integerValue];
            
            if (unreadCount == 0)
            {
                self.itemNotifsButton.selected = NO;
                return;
            }
            
            self.itemNotifsButton.selected = YES;
            
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TopBar.itemNotifLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            self.itemNotifsLabel = [sheet makeLabel];
            self.itemNotifsLabel.text = [NSString stringWithFormat:@"%d", unreadCount];
            [self.itemNotifsButton addSubview:self.itemNotifsLabel];
            self.itemNotifsLabel.adjustsFontSizeToFitWidth = YES;
        }];

    }
}


- (void)updateSettings:(BOOL)enabled
{
    if (!enabled)
    {
        self.itemSettings.enabled = NO;
        self.itemSettingsButton.selected = NO;
        self.itemSettingsButton.enabled = NO;
        self.itemSettingsButton.hidden = YES;
        
        [self.itemSettingsButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        self.itemSettings.enabled = YES;
        self.itemSettingsButton.enabled = YES;
        self.itemSettingsButton.hidden = NO;
        [self.itemSettingsButton addTarget:self action:@selector(onSettings:) forControlEvents:UIControlEventTouchUpInside];
        
    }
}






















- (void)onMenu:(id)sender
{
    BOOL run = YES;
    
    if ([self.delegate respondsToSelector:@selector(topBarItemClicked:)])
        run = [self.delegate topBarItemClicked:TopBarItemMenu];
    
    if (run)
        [self runItem:TopBarItemMenu];
}


- (void)onBack:(id)sender
{
    BOOL run = YES;
    
    if ([self.delegate respondsToSelector:@selector(topBarItemClicked:)])
        run = [self.delegate topBarItemClicked:TopBarItemBack];

    if (run)
        [self runItem:TopBarItemBack];
}



- (void)onHd:(id)sender
{
    BOOL run = YES;
    
    if ([self.delegate respondsToSelector:@selector(topBarItemClicked:)])
        run = [self.delegate topBarItemClicked:TopBarItemHd];
    
    if (run)
        [self runItem:TopBarItemHd];
}




- (void)onSearch:(id)sender
{
    BOOL run = YES;
    
    if ([self.delegate respondsToSelector:@selector(topBarItemClicked:)])
        run = [self.delegate topBarItemClicked:TopBarItemSearch];
    
    if (run)
        [self runItem:TopBarItemSearch];
}






- (void)onNotif:(id)sender
{
    BOOL run = YES;
    
    if ([self.delegate respondsToSelector:@selector(topBarItemClicked:)])
        run = [self.delegate topBarItemClicked:TopBarItemNotif];

    if (run)
        [self runItem:TopBarItemNotif];
}

- (void)onTrash:(id)sender
{
    BOOL run = YES;
    
    if ([self.delegate respondsToSelector:@selector(topBarItemClicked:)])
        run = [self.delegate topBarItemClicked:TopBarItemTrash];

    if (run)
        [self runItem:TopBarItemTrash];
}


- (void)onEdit:(id)sender {
    
    BOOL run = YES;
    
    if ([self.delegate respondsToSelector:@selector(topBarItemClicked:)])
        run = [self.delegate topBarItemClicked:TopBarItemEdit];
    
    if (run)
        [self runItem:TopBarItemEdit];
    
}



- (void)onSettings:(id)sender
{
    BOOL run = YES;
    
    if ([self.delegate respondsToSelector:@selector(topBarItemClicked:)])
        run = [self.delegate topBarItemClicked:TopBarItemSettings];
    
    if (run)
        [self runItem:TopBarItemSettings];
}


- (void)onNowPlaying:(id)sender
{
    BOOL run = YES;
    
    if ([self.delegate respondsToSelector:@selector(topBarItemClicked:)])
        run = [self.delegate topBarItemClicked:TopBarItemNowPlaying];
    
    if (run)
        [self runItem:TopBarItemNowPlaying];
}











- (void)runItem:(TopBarItemId)itemId
{
    if (itemId == TopBarItemMenu)
    {
        if ([APPDELEGATE.slideController underLeftShowing])
            [APPDELEGATE.slideController resetTopView];
        else
            [  APPDELEGATE.slideController anchorTopViewTo:ECRight];
    }
    
    else if (itemId == TopBarItemBack)
    {
        [APPDELEGATE.navigationController popViewControllerAnimated:YES];
    }

    else if (itemId == TopBarItemHd)
    {
        // show gifts
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Gift.popover" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        CGSize popoverSize = sheet.frame.size;
        
        GiftsViewController* view = [[GiftsViewController alloc] initWithNibName:@"GiftsViewController" bundle:nil];
        FPPopoverController* popover = [[FPPopoverController alloc] initWithViewController:view];
        popover.contentSize = popoverSize;
        popover.arrowDirection = FPPopoverArrowDirectionAny;
        view.popover = popover;
        [popover presentPopoverFromView:self.itemHdButton];
        [view release];
        [popover release];
    }

    else if (itemId == TopBarItemSearch)
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Search.popover" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        CGSize popoverSize = sheet.frame.size;
        
        RadioSearchViewController* view = [[RadioSearchViewController alloc] initWithNibName:@"RadioSearchViewController" bundle:nil];
        FPPopoverController* popover = [[FPPopoverController alloc] initWithViewController:view];
        popover.contentSize = popoverSize;
        popover.arrowDirection = FPPopoverArrowDirectionAny;
        view.popover = popover;
        [popover presentPopoverFromView:self.itemSearchButton];
        [view release];
        [popover release];
    }
    
    
    
    else if (itemId == TopBarItemNotif)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_NOTIFICATIONS object:nil];
    }
        
    else if (itemId == TopBarItemSettings)
    {
        // nothing
    }
    
    else if (itemId == TopBarItemTrash)
    {
        // nothing
    }

    else if (itemId == TopBarItemEdit)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_EDIT_PROFIL object:nil];
    }

    else if (itemId == TopBarItemAdd)
    {
        // nothing
    }

    else if (itemId == TopBarItemNowPlaying)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_RADIO object:[AudioStreamManager main].currentRadio];    
    }

}


- (void)onNotifDidLogout:(NSNotification*)notif
{
    [self updateHd];
    [self updateNotifs];
    
    BOOL enabled = NO;
    
    if ([YasoundSessionManager main].registered)
    {
        if ([AudioStreamManager main].currentRadio != nil)
        {
            enabled = ([[YasoundDataProvider main].user.id intValue] == [[AudioStreamManager main].currentRadio.creator.id intValue]);
        }
    }

    [self updateSettings:enabled];
}

- (void)onNotifDidLogin:(NSNotification*)notif
{
    [self updateHd];
    [self updateNotifs];
    
    BOOL enabled = NO;
    
    if ([YasoundSessionManager main].registered)
    {
        if ([AudioStreamManager main].currentRadio != nil)
        {
            enabled = ([[YasoundDataProvider main].user.id intValue] == [[AudioStreamManager main].currentRadio.creator.id intValue]);
        }
    }

    [self updateSettings:enabled];
}


- (void)onNotifsChanged:(NSNotification*)notif {
    [self updateNotifs];
}

- (void)onHdChanged:(NSNotification*)notif {
    [self updateHd];
}




@end
