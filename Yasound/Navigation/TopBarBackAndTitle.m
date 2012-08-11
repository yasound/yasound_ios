//
//  TopBarBackAndTitle.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 18/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "TopBarBackAndTitle.h"
#import "Theme.h"
#import "YasoundAppDelegate.h"

@implementation TopBarBackAndTitle

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

    NSString* strBack = NSLocalizedString(@"Navigation.back", nil);
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TopBar.itemBack" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIButton* btn = [sheet makeButton];
    [btn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* itemBack = [[UIBarButtonItem alloc] initWithCustomView:btn];
    

    BundleStylesheet* sheetLabel = [[Theme theme] stylesheetForKey:@"TopBar.itemBackLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* backLabel = [sheetLabel makeLabel];
    backLabel.text = strBack;
    [btn addSubview:backLabel];
    
    // flexible space
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    
    UIBarButtonItem* itemTitle = nil;
    if ([self.delegate respondsToSelector:@selector(topBarTitle)])
    {
        NSString* title = [self.delegate topBarTitle];
        itemTitle = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    else if ([self.delegate respondsToSelector:@selector(topBarTitleView)])
    {
        UIView* titleView = [self.delegate topBarTitleView];
        itemTitle = [[UIBarButtonItem alloc] initWithCustomView:titleView];
    }

    
    if (itemTitle == nil)
        self.customItems = [NSMutableArray arrayWithObjects:itemBack, flexibleSpace, nil];
    else
        self.customItems = [NSMutableArray arrayWithObjects:itemBack, itemTitle, flexibleSpace, nil];
    
    [self setItems:self.customItems];


//    CGSize suggestedSizeCancel = [strCancel sizeWithFont:[sheetLabel makeFont] constrainedToSize:CGSizeMake(FLT_MAX, FLT_MAX) lineBreakMode:UILineBreakModeClip];
//    CGSize suggestedSizeSave = [strSave sizeWithFont:[sheetLabel makeFont] constrainedToSize:CGSizeMake(FLT_MAX, FLT_MAX) lineBreakMode:UILineBreakModeClip];
//
//    NSString* sheetnameBlack;
//    NSString* sheetnameBlue;
//    if (suggestedSizeCancel.width <= 48)
//        sheetnameBlack = @"TopBar.itemEmptyBlack1";
//    else if (suggestedSizeCancel.width <= 68)
//        sheetnameBlack = @"TopBar.itemEmptyBlack2";
//    else
//        sheetnameBlack = @"TopBar.itemEmptyBlack3";
//
//    if (suggestedSizeSave.width <= 48)
//        sheetnameBlue = @"TopBar.itemEmptyBlue1";
//    else if (suggestedSizeSave.width <= 68)
//        sheetnameBlue = @"TopBar.itemEmptyBlue2";
//    else
//        sheetnameBlue = @"TopBar.itemEmptyBlue3";
//    
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:sheetnameBlack retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    UIButton* btn = [sheet makeButton];
//
//    sheet = [[Theme theme] stylesheetForKey:@"TopBar.itemEmptyLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    UILabel* label = [sheet makeLabel];
//    label.text = strCancel;
//    label.frame = CGRectMake(8, -1, btn.frame.size.width-16, btn.frame.size.height);
//    [btn addSubview:label];
//    
//    [btn addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem* itemCancel = [[UIBarButtonItem alloc] initWithCustomView:btn];
//
//    // flexible space
//    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//
//    sheet = [[Theme theme] stylesheetForKey:sheetnameBlue retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    btn = [sheet makeButton];
//
//    sheet = [[Theme theme] stylesheetForKey:@"TopBar.itemEmptyLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    label = [sheet makeLabel];
//    label.text = strSave;
//    label.frame = CGRectMake(8, -1, btn.frame.size.width-16, btn.frame.size.height);
//    [btn addSubview:label];
//
//    [btn addTarget:self action:@selector(onSave:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem* itemSave = [[UIBarButtonItem alloc] initWithCustomView:btn];
//
//    [self setItems:[NSArray arrayWithObjects:itemCancel, flexibleSpace, itemSave, nil]];
}



- (void)onBack:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(topBarBack:)])
        [self.delegate topBarBack];

    [APPDELEGATE.navigationController popViewControllerAnimated:YES];
}


- (void)showAddItem
{
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TopBar.itemAdd" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIButton* btn = [sheet makeButton];
    
    [btn addTarget:self action:@selector(onAdd:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    if (self.customItems.count < 3)
        [self.customItems addObject:item];
    else
        [self.customItems replaceObjectAtIndex:2 withObject:item];
    
    [self setItems:self.customItems];
}







@end
