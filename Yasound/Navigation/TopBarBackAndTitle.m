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
#import "CustomSizedButtonView.h"

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

    // back button
    CustomSizedButtonView* customView = [[CustomSizedButtonView alloc] initWithThemeRef:@"back" title:NSLocalizedString(@"Navigation.back", nil)];
    customView.target = self;
    customView.action = @selector(onBack:);
    UIBarButtonItem* itemBack = [[UIBarButtonItem alloc] initWithCustomView:customView];
    

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

}

 

- (void)onBack:(id)sender
{
    BOOL goBack = YES;
    
    if ([self.delegate respondsToSelector:@selector(topBarBackClicked)])
        goBack = [self.delegate topBarBackClicked];

    if (goBack)
        [APPDELEGATE.navigationController popViewControllerAnimated:YES];
}


- (void)showAddItemWithTarget:(id)target action:(SEL)action
{
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TopBar.itemAdd" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIButton* btn = [sheet makeButton];
    
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    if (self.customItems.count < 3)
        [self.customItems addObject:item];
    else
        [self.customItems replaceObjectAtIndex:2 withObject:item];
    
    [self setItems:self.customItems];
}



- (void)showEditItemWithTarget:(id)target action:(SEL)action
{
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:target action:action];
    
    if (self.customItems.count < 3)
        [self.customItems addObject:item];
    else
        [self.customItems replaceObjectAtIndex:2 withObject:item];
    
    [self setItems:self.customItems];
}





@end
