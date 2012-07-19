//
//  WheelSelector.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 19/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "WheelSelector.h"
#import "Theme.h"

@implementation WheelSelector

@synthesize wheelDelegate;
@synthesize items;

#define ITEM_TEXT 0
#define ITEM_WIDTH 1

- (void)awakeFromNib
{
//    self = [super initWithFrame:frame];
//    if (self) 
//    {
        self.items = [[NSMutableArray alloc] init];
        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"WheelSelector.label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIFont* font = [sheet makeFont];
        
        [self addItem:NSLocalizedString(@"WheelSelector_Favorites", nil) withFont:font];
        [self addItem:NSLocalizedString(@"WheelSelector_Genre", nil) withFont:font];
        [self addItem:NSLocalizedString(@"WheelSelector_Selection", nil) withFont:font];
        [self addItem:NSLocalizedString(@"WheelSelector_Friends", nil) withFont:font];
        [self addItem:NSLocalizedString(@"WheelSelector_Top", nil) withFont:font];
        
        CGFloat x = 8;
        CGFloat y = 8;
        CGFloat h = 32;
        
        for (NSArray* item in self.items)
        {
            UILabel* label = [sheet makeLabel];
            CGFloat width = [[item objectAtIndex:ITEM_WIDTH] floatValue];
            label.text = [item objectAtIndex:ITEM_TEXT];
            CGRect frame = CGRectMake(x, y, width, h);
            label.frame = frame;
            
            [self addSubview:label];
            self.contentSize = CGSizeMake(x + width, h);
            
            x += width;
            x += 8;
        }
        
//    }
//    return self;
}


- (void)addItem:(NSString*)item  withFont:(UIFont*)font
{
    CGSize suggestedSize = [item sizeWithFont:font constrainedToSize:CGSizeMake(FLT_MAX, 32) lineBreakMode:UILineBreakModeClip];

    [self.items addObject:[NSArray arrayWithObjects:item, [NSNumber numberWithFloat:suggestedSize.width], nil]];
}




#pragma mark - UIScrollViewDelegate


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    if (!_waitingForPreviousEvents)
//    {
//        float offset = scrollView.contentOffset.y;
//        float contentHeight = scrollView.contentSize.height;
//        float viewHeight = scrollView.bounds.size.height;
//        
//        if (offset + viewHeight > contentHeight + WALL_WAITING_ROW_HEIGHT)
//        {
//            [self askForPreviousEvents];
//        }
//    }
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
