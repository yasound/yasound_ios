//
//  TopBar.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 18/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "TopBar.h"
#import "Theme.h"

@implementation TopBar

@synthesize delegate;


- (void)awakeFromNib
{
    // set background
    if ([self respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)]) 
        [self setBackgroundImage:[UIImage imageNamed:@"topBarBkg.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    else 
        [self insertSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topBarBkg.png"]] autorelease] atIndex:0];

    // add "back" bar item
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TopBar.ItemMenu" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIButton* btn = [sheet makeButton];
    [btn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* itemBack = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    
    // add "HD" item
    UIBarButtonItem* itemHD = [[UIBarButtonItem alloc] initWithCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"barItemHdOff.png"]]];
    

    [self setItems:[NSArray arrayWithObjects:itemBack, itemHD, nil]];

}



- (void)onBack:(id)sender
{
    [self.delegate topBarBackItemClicked];
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
