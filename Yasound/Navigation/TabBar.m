//
//  TabBar.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 20/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "TabBar.h"
#import "Theme.h"
#import "RootViewController.h"
#import "YasoundSessionManager.h"

@implementation TabBar


@synthesize tabBarDelegate;
@synthesize buttons;
@synthesize labels;
//@synthesize selectedButton;
@synthesize selectedIndex;

- (void)awakeFromNib
{
    self.selectedIndex = -1;
    //    self.selectedButton = nil;
    
    CGFloat x = 0;
    CGFloat y = 0;
    NSInteger tag = 0;
    NSArray* tabs = [NSArray arrayWithObjects:@"TabBar.selection", @"TabBar.favorites", @"TabBar.myRadios", @"TabBar.gifts", @"TabBar.profil", nil];
    
    self.buttons = [[NSMutableArray alloc] init];
    self.labels = [[NSMutableArray alloc] init];
    
    for (NSString* tab in tabs)
    {
        // button
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:tab retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIButton* btn = [sheet makeButton];
        btn.frame = CGRectMake(x, y, btn.frame.size.width, btn.frame.size.height);
        btn.tag = tag;
        [btn addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [btn addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:btn];
        
        [self addSubview:btn];
        
        // label
        sheet = [[Theme theme] stylesheetForKey:@"TabBar.label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UILabel* label = [sheet makeLabel];
        label.frame = CGRectMake(x + label.frame.origin.x, label.frame.origin.y, label.frame.size.width, label.frame.size.height);
        label.text = NSLocalizedString(tab, nil);
        [self.labels addObject:label];
        
        [self addSubview:label];

        // iterate
        x += btn.frame.size.width;
        tag++;
    }

    
    // disabled "gifts" for now
    //#FIXME: MatDebug enable gifts for now
//    [[self.buttons objectAtIndex:TabIndexGifts] setEnabled:NO];
//    [[self.labels objectAtIndex:TabIndexGifts] setEnabled:NO];
    
}



- (void)onButtonPressed:(id)sender
{
    UIButton* btn = sender;

    if (self.selectedIndex == btn.tag)
        return;
//    if (self.selectedButton == btn)
//        return;
    
    for (UIButton* button in self.buttons)
        button.selected = NO;

    btn.selected = YES;
}


- (void)onButtonClicked:(id)sender
{
    UIButton* btn = sender;
    
    if (self.selectedIndex == btn.tag)
        return;

//    self.selectedButton = btn;
        
    BOOL callDelegate = NO;
    
    BOOL isConnected = [YasoundSessionManager main].registered;
    
    if (btn.tag == TabIndexSelection)
    {
        if ((self.selectedIndex != TabIndexSelection) && (self.selectedIndex != TabIndexFavorites))
        {
            NSNumber* animated = [NSNumber numberWithBool:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_SELECTION object:animated];
        }
        else
            callDelegate = YES;
    }
    else if (isConnected && (btn.tag == TabIndexFavorites))
    {
        if ((self.selectedIndex != TabIndexSelection) && (self.selectedIndex != TabIndexFavorites))
        {
            NSNumber* animated = [NSNumber numberWithBool:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_FAVORITES object:animated];
        }
        else
            callDelegate = YES;
    }
    else if (isConnected && (btn.tag == TabIndexMyRadios))
    {
        NSNumber* animated = [NSNumber numberWithBool:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_MYRADIOS object:animated];
    }
    else if (isConnected && (btn.tag == TabIndexGifts))
    {
        NSNumber* animated = [NSNumber numberWithBool:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_GIFTS object:animated];
    }
    else if (isConnected && (btn.tag == TabIndexProfil))
    {
        NSNumber* animated = [NSNumber numberWithBool:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_PROFIL object:animated];
    }

    
    self.selectedIndex = btn.tag;
    

    // call delegate
    if ([self.tabBarDelegate respondsToSelector:@selector(tabBarDidSelect:)])
        [self.tabBarDelegate tabBarDidSelect:btn.tag];
}


- (void)setTabSelected:(NSInteger)tabIndex
{
    UIButton* btn = [self.buttons objectAtIndex:tabIndex];
    
    if (self.selectedIndex == btn.tag)
        return;
    //    if (self.selectedButton == btn)
    //        return;
    
    for (UIButton* button in self.buttons)
        button.selected = NO;
    
    btn.selected = YES;
//    self.selectedButton = btn;
    self.selectedIndex = btn.tag;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
