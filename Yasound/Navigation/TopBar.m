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
#import "SettingsViewController.h"
#import "NotificationCenterViewController.h"
#import "YasoundSessionManager.h"

@implementation TopBar

@synthesize delegate;
@synthesize customItems;


- (void)awakeFromNib
{
    self.backgroundColor = [UIColor blackColor];
    
    // set background
    if ([self respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)]) 
        [self setBackgroundImage:[UIImage imageNamed:@"topBarBkg.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    else 
        [self insertSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topBarBkg.png"]] autorelease] atIndex:0];

    // "back"  item
    BundleStylesheet* sheet = nil;
    UIButton* btn = nil;
    UIBarButtonItem* itemBack = nil;
    
//    items
//    
//    if (![RootViewController menuIsCurrentScreen])
//    {
        sheet = [[Theme theme] stylesheetForKey:@"TopBar.itemMenu" retainStylesheet:YES overwriteStylesheet:NO error:nil];
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




- (void)onBack:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(topBarBackItemClicked:)])
        [self.delegate topBarBackItemClicked:TopBarItemBack];

    [APPDELEGATE.navigationController popViewControllerAnimated:YES];
}


- (void)onNotif:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(topBarBackItemClicked:)])
        [self.delegate topBarBackItemClicked:TopBarItemNotif];

    NotificationCenterViewController* view = [[NotificationCenterViewController alloc] initWithNibName:@"NotificationCenterViewController" bundle:nil];
    [APPDELEGATE.navigationController pushViewController:view animated:YES];
    [view release];
}

- (void)onTrash:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(topBarBackItemClicked:)])
        [self.delegate topBarBackItemClicked:TopBarItemTrash];
}

- (void)onSettings:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(topBarBackItemClicked:)])
        [self.delegate topBarBackItemClicked:TopBarItemSettings];
    
    SettingsViewController* view = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil forRadio:[AudioStreamManager main].currentRadio];
    [APPDELEGATE.navigationController pushViewController:view animated:YES];
    [view release];
    
}


- (void)onNowPlaying:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(topBarBackItemClicked:)])
        [self.delegate topBarBackItemClicked:TopBarItemNowPlaying];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_RADIO object:[AudioStreamManager main].currentRadio];
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
