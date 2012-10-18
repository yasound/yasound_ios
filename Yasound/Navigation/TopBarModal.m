//
//  TopBarModal.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 18/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "TopBarModal.h"
#import "Theme.h"
#import "YasoundAppDelegate.h"

@implementation TopBarModal

@synthesize delegate;
@synthesize actionButton;


- (void)awakeFromNib
{
    self.backgroundColor = [UIColor blackColor];
    
    // set background
    if ([self respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)])
        [self setBackgroundImage:[UIImage imageNamed:@"topBarBkg.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    else
        [self insertSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topBarBkg.png"]] autorelease] atIndex:0];
    
    NSString* strCancel = NSLocalizedString(@"Navigation.cancel", nil);
    if ([self.delegate respondsToSelector:@selector(titleForCancelButton)])
        strCancel = [self.delegate titleForCancelButton];

    NSString* strSave = NSLocalizedString(@"Navigation.save", nil);
    if ([self.delegate respondsToSelector:@selector(titleForActionButton)])
        strSave = [self.delegate titleForActionButton];
    
    
    
    
    BundleStylesheet* sheetLabel = [[Theme theme] stylesheetForKey:@"TopBar.itemEmptyLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    
    CGSize suggestedSizeCancel = [strCancel sizeWithFont:[sheetLabel makeFont] constrainedToSize:CGSizeMake(FLT_MAX, FLT_MAX) lineBreakMode:UILineBreakModeClip];
    CGSize suggestedSizeSave = [strSave sizeWithFont:[sheetLabel makeFont] constrainedToSize:CGSizeMake(FLT_MAX, FLT_MAX) lineBreakMode:UILineBreakModeClip];
    
    NSString* sheetnameBlack;
    if (suggestedSizeCancel.width <= 48)
        sheetnameBlack = @"TopBar.itemEmptyBlack1";
    else if (suggestedSizeCancel.width <= 68)
        sheetnameBlack = @"TopBar.itemEmptyBlack2";
    else
        sheetnameBlack = @"TopBar.itemEmptyBlack3";
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:sheetnameBlack retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIButton* btn = [sheet makeButton];
    
    sheet = [[Theme theme] stylesheetForKey:@"TopBar.itemEmptyLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = strCancel;
    label.frame = CGRectMake(8, -1, btn.frame.size.width-16, btn.frame.size.height);
    [btn addSubview:label];
    
    [btn addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* itemCancel = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.actionButton = nil;
    
    BOOL shouldShowActionButton = YES;
    if ([self.delegate respondsToSelector:@selector(shouldShowActionButton)])
        shouldShowActionButton = [self.delegate shouldShowActionButton];

    if (shouldShowActionButton)
        self.actionButton = [[UIBarButtonItem alloc] initWithTitle:strSave style:UIBarButtonItemStyleBordered target:self action:@selector(onSave:)];
    
    
    if ([self.delegate respondsToSelector:@selector(tintForActionButton)])
    {
        UIColor* color = [self.delegate tintForActionButton];
        
        if ([self.actionButton respondsToSelector:@selector(setTintColor:)])
        {
            [self.actionButton performSelector:@selector(setTintColor:) withObject:color];
        }
        
    }
    
    NSString* title = nil;
    if ([self.delegate respondsToSelector:@selector(topBarModalTitle)])
    {
        title = [self.delegate topBarModalTitle];
    }
    UIBarButtonItem* itemTitle = nil;
    if (title)
    {
        itemTitle = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:nil action:nil];
        
    }
    
    if (itemTitle)
    {
        // flexible space
        UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem* flexibleSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [self setItems:[NSArray arrayWithObjects:itemCancel, flexibleSpace, itemTitle, flexibleSpace2, self.actionButton, nil]];
    }
    else
    {
        // flexible space
        UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [self setItems:[NSArray arrayWithObjects:itemCancel, flexibleSpace, self.actionButton, nil]];
    }
        
}



- (void)onCancel:(id)sender
{
    BOOL run = YES;
    
    if ([self.delegate respondsToSelector:@selector(topBarCancel)])
        run = [self.delegate topBarCancel];
    
    if (run)
        [APPDELEGATE.navigationController dismissModalViewControllerAnimated:YES];
}


- (void)onSave:(id)sender
{
    BOOL run = YES;
    
    if ([self.delegate respondsToSelector:@selector(topBarSave)])
        run = [self.delegate topBarSave];
    
    if (run)
        [APPDELEGATE.navigationController dismissModalViewControllerAnimated:YES];
}


- (void)hideCancelButton
{
    NSMutableArray* items = [NSMutableArray arrayWithArray:self.items];
    [items removeObjectAtIndex:0];
    [self setItems:items];
    
}



@end
