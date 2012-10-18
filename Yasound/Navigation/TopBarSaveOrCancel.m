//
//  TopBarSaveOrCancel.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 18/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "TopBarSaveOrCancel.h"
#import "Theme.h"
#import "YasoundAppDelegate.h"

@implementation TopBarSaveOrCancel

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

    // flexible space
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    self.actionButton = [[UIBarButtonItem alloc] initWithTitle:strSave style:UIBarButtonItemStyleBordered target:self action:@selector(onSave:)];
    
    
    if ([self.delegate respondsToSelector:@selector(tintForActionButton)])
    {
        UIColor* color = [self.delegate tintForActionButton];
        
        if ([self.actionButton respondsToSelector:@selector(setTintColor:)])
        {
            [self.actionButton performSelector:@selector(setTintColor:) withObject:color];
        }
        
    }


    [self setItems:[NSArray arrayWithObjects:itemCancel, flexibleSpace, self.actionButton, nil]];
}



- (void)onCancel:(id)sender
{
    BOOL run = YES;
    
    if ([self.delegate respondsToSelector:@selector(topBarCancel)])
        run = [self.delegate topBarCancel];

    if (run)
        [APPDELEGATE.navigationController popViewControllerAnimated:YES];
}


- (void)onSave:(id)sender
{
    BOOL run = YES;
    
    if ([self.delegate respondsToSelector:@selector(topBarSave)])
        run = [self.delegate topBarSave];
    
    if (run)
        [APPDELEGATE.navigationController popViewControllerAnimated:YES];
}


- (void)hideCancelButton
{
    NSMutableArray* items = [NSMutableArray arrayWithArray:self.items];
    [items removeObjectAtIndex:0];
    [self setItems:items];

}



@end
