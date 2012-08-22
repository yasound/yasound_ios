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

@implementation TopBar

@synthesize delegate;
@synthesize customItems;


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
    // "back"  item
    BundleStylesheet* sheet = nil;
    UIButton* btn = nil;
    UIBarButtonItem* itemBack = nil;
    
//    items
//    
//    if (![RootViewController menuIsCurrentScreen])
//    {
        sheet = [[Theme theme] stylesheetForKey:@"TopBar.itemBack" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        btn = [sheet makeButton];
        [btn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
        itemBack = [[UIBarButtonItem alloc] initWithCustomView:btn];
//    }
//    else
//    {
//        itemBack = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];    
//    }
    
    // "HD" item
    UIBarButtonItem* itemHD = [[UIBarButtonItem alloc] initWithCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"barItemHdOff.png"]]];
    
    //  "notif"  item
    sheet = [[Theme theme] stylesheetForKey:@"TopBar.itemNotif" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    btn = [sheet makeButton];
    if ([YasoundSessionManager main].registered)
    {
        [btn addTarget:self action:@selector(onNotif:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        btn.enabled = NO;
    }
    UIBarButtonItem* itemNotif = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
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

    self.customItems = [NSMutableArray arrayWithObjects:itemBack, flexibleSpace, itemHD, flexibleSpace, itemNotif, flexibleSpace, itemNowPlaying, nil];
    
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
    UIButton* btn = [sheet makeButton];

    if (enabled)
    {
        [btn addTarget:self action:@selector(onSettings:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        btn.enabled = NO;
    }

    UIBarButtonItem* itemSettings = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    [self.customItems replaceObjectAtIndex:6 withObject:itemSettings];
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


- (void)showAddItem
{
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TopBar.itemAdd" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIButton* btn = [sheet makeButton];
    
    [btn addTarget:self action:@selector(onAdd:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)onAdd:(id)sender
{
    BOOL run = YES;
    
    if ([self.delegate respondsToSelector:@selector(topBarItemClicked:)])
        run = [self.delegate topBarItemClicked:TopBarItemAdd];

    if (run)
        [self runItem:TopBarItemAdd];
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
        [APPDELEGATE.navigationController popViewControllerAnimated:YES];

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
    [self update];
}

- (void)onNotifDidLogin:(NSNotification*)notif
{
    [self update];
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
