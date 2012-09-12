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

#import "FPPopoverController.h"

@implementation TopBar

@synthesize delegate;
@synthesize customItems;
@synthesize itemHdButton;


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


- (void)awakeFromNib
{
    self.backgroundColor = [UIColor blackColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifDidLogout:) name:NOTIF_DID_LOGOUT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifDidLogin:) name:NOTIF_DID_LOGIN object:nil];
    
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
    btn = [sheet makeButton];
    [btn addTarget:self action:@selector(onNowPlaying:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* itemNowPlaying = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    // init "now playing" button
    if ([AudioStreamManager main].currentRadio == nil)
        [btn setEnabled:NO];


    // flexible space
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    self.customItems = [NSMutableArray arrayWithObjects:itemBack, flexibleSpace, self.itemHd, flexibleSpace, self.itemNotifs, flexibleSpace, itemNowPlaying, nil];
    
    [self setItems:self.customItems];

}









- (void)hideBackItem:(BOOL)hide
{
    if (hide)
    {
        UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [self.customItems replaceObjectAtIndex:0 withObject:flexibleSpace];
        [self setItems:self.customItems];
    }
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
    
    [self.customItems replaceObjectAtIndex:6 withObject:self.itemSettings];
    [self setItems:self.customItems];
}


- (void)showTrashItem;
{
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TopBar.itemTrash" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIButton* btn = [sheet makeButton];
    
    [btn addTarget:self action:@selector(onTrash:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    [self.customItems replaceObjectAtIndex:6 withObject:item];
    [self setItems:self.customItems];
}





- (void)showMenuItem
{
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TopBar.itemMenu" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIButton* btn = [sheet makeButton];
    
    [btn addTarget:self action:@selector(onMenu:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    [self.customItems replaceObjectAtIndex:0 withObject:item];
    [self setItems:self.customItems];
}











- (void)updateHd
{
    self.itemHd.enabled = YES;
    self.itemHdButton.enabled = YES;
    [self.itemHdButton addTarget:self action:@selector(onHd:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[YasoundDataProvider main].user permission:PERM_HD])
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
        
//        [self.itemNotifsButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
        [self.itemNotifsButton removeTarget:self action:@selector(onHd:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        self.itemNotifs.enabled = YES;
        self.itemNotifsButton.enabled = YES;
        [self.itemNotifsButton addTarget:self action:@selector(onHd:) forControlEvents:UIControlEventTouchUpInside];
    }
}



- (void)updateSettings
{
    BOOL enabled = NO;
    
    if ([YasoundSessionManager main].registered)
    {
        if ([AudioStreamManager main].currentRadio != nil)
        {
            enabled = ([[YasoundDataProvider main].user.id intValue] == [[AudioStreamManager main].currentRadio.creator.id intValue]);
        }
    }
    
    
    if (!enabled)
    {
        self.itemSettings.enabled = NO;
        self.itemSettingsButton.selected = NO;
        self.itemSettingsButton.enabled = NO;
        
        [self.itemSettingsButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        self.itemSettings.enabled = YES;
        self.itemSettingsButton.enabled = YES;
        [self.itemSettingsButton addTarget:self action:@selector(onHd:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([[YasoundDataProvider main].user permission:PERM_HD])
            self.itemSettingsButton.selected = YES;
        else
            self.itemSettingsButton.selected = NO;
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
    //LBDEBUG TEMPORARLY
    return;
    
    BOOL run = YES;
    
    if ([self.delegate respondsToSelector:@selector(topBarItemClicked:)])
        run = [self.delegate topBarItemClicked:TopBarItemHd];
    
    if (run)
        [self runItem:TopBarItemHd];
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

//- (void)onAdd:(id)sender
//{
//    BOOL run = YES;
//    
//    if ([self.delegate respondsToSelector:@selector(topBarItemClicked:)])
//        run = [self.delegate topBarItemClicked:TopBarItemAdd];
//
//    if (run)
//        [self runItem:TopBarItemAdd];
//}

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
//        PurchaseViewController* view = [[PurchaseViewController alloc] initWithNibName:@"PurchaseViewController" bundle:nil];
//        [APPDELEGATE.navigationController pushViewController:view animated:YES];
//        [view release];
        
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

    else if (itemId == TopBarItemNotif)
    {
        NotificationCenterViewController* view = [[NotificationCenterViewController alloc] initWithNibName:@"NotificationCenterViewController" bundle:nil];
        [APPDELEGATE.navigationController pushViewController:view animated:YES];
        [view release];
    }
        
    else if (itemId == TopBarItemSettings)
    {
        // nothing
    }
    
    else if (itemId == TopBarItemTrash)
    {
        // nothing
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
    [self updateSettings];
}

- (void)onNotifDidLogin:(NSNotification*)notif
{
    [self updateHd];
    [self updateNotifs];
    [self updateSettings];
}

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) 
//    {
//    }
//    return self;
//}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
