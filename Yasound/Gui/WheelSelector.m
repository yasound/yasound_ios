//
//  WheelSelector.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 19/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "WheelSelector.h"
#import "Theme.h"
#include <QuartzCore/QuartzCore.h>

@implementation WheelSelector

@synthesize wheelDelegate;
@synthesize items;
@synthesize needsToStick;

#define ITEM_TEXT 0
#define ITEM_WIDTH 1
#define ITEM_STICKY_POS 2
#define ITEM_STICKY_LIMIT 3

- (void)awakeFromNib
{
//    self = [super initWithFrame:frame];
//    if (self) 
//    {
    
    self.needsToStick = NO;
    
    // compute selector's options
        self.items = [[NSMutableArray alloc] init];
        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"WheelSelector.label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIFont* font = [sheet makeFont];
        
        [self addItem:NSLocalizedString(@"WheelSelector_Favorites", nil) withFont:font];
        [self addItem:NSLocalizedString(@"WheelSelector_Genre", nil) withFont:font];
        [self addItem:NSLocalizedString(@"WheelSelector_Selection", nil) withFont:font];
        [self addItem:NSLocalizedString(@"WheelSelector_Friends", nil) withFont:font];
        [self addItem:NSLocalizedString(@"WheelSelector_Top", nil) withFont:font];
        
    CGFloat marginLeft = (self.frame.size.width /2.f) - ([[[self.items objectAtIndex:0] objectAtIndex:ITEM_WIDTH] floatValue] /2.f);
    CGFloat marginRight = (self.frame.size.width /2.f) - ([[[self.items objectAtIndex:(self.items.count-1)] objectAtIndex:ITEM_WIDTH] floatValue]);

    CGFloat x = marginLeft;
        CGFloat y = 8;
        CGFloat h = 32;
        CGFloat spacing = 48;
        CGFloat width = 0;
    
        // add labels for the selector options, compute the contents size, and the sticky positions of the scrollview
        for (NSMutableArray* item in self.items)
        {
            UILabel* label = [sheet makeLabel];
            width = [[item objectAtIndex:ITEM_WIDTH] floatValue];
            
            // set the "sticky" position for this item (<=> the center position)
            [item addObject:[NSNumber numberWithFloat:(x + width /2.f)]];
            
            // set the "sticky" limit for this item (<=> where the influence of the next item begins)
            [item addObject:[NSNumber numberWithFloat:(x + width + spacing/2.f)]];
            
            label.text = [item objectAtIndex:ITEM_TEXT];
            CGRect frame = CGRectMake(x, y, width, h);
            label.frame = frame;
            
            [self addSubview:label];
            
            x += width;
            x += spacing;
        }

    self.contentSize = CGSizeMake(x - width + marginRight, self.contentSize.height);
    [self setShowsHorizontalScrollIndicator:NO];
    [self setShowsVerticalScrollIndicator:NO];
    self.delegate = self;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
//    self.decelerationRate = UIScrollViewDecelerationRateNormal;
    
//    // add selector visual indicator
//    sheet = [[Theme theme] stylesheetForKey:@"WheelSelector.indicator" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    UIImageView* indicator = [sheet makeImage];
//    indicator.frame = CGRectMake(self.frame.size.width/2.f - indicator.frame.size.width/2.f, self.frame.size.height - indicator.frame.size.height, indicator.frame.size.width, indicator.frame.size.height);
//    [self addSubview:indicator];

    sheet = [[Theme theme] stylesheetForKey:@"WheelSelector.indicator" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImage* indicatorImage = [sheet image];
    CGRect indicatorFrame = CGRectMake(self.frame.size.width/2.f - indicatorImage.size.width/2.f, self.frame.origin.y + self.frame.size.height - indicatorImage.size.height, indicatorImage.size.width, indicatorImage.size.height);
    CALayer* indicatorLayer = [CALayer layer];
    indicatorLayer.contents = (id)[indicatorImage CGImage];
    indicatorLayer.frame = indicatorFrame;
    
    [[self.superview layer] addSublayer:indicatorLayer];
    
}


- (void)addItem:(NSString*)item  withFont:(UIFont*)font
{
    CGSize suggestedSize = [item sizeWithFont:font constrainedToSize:CGSizeMake(FLT_MAX, 32) lineBreakMode:UILineBreakModeClip];

    [self.items addObject:[NSMutableArray arrayWithObjects:item, [NSNumber numberWithFloat:suggestedSize.width], nil]];
}




#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.needsToStick = decelerate;
    if (decelerate)
        return;
    
    [self stick];
}



- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (!self.needsToStick)
        return;
    
    self.needsToStick = NO;
    [self stick];
    
}

- (void)stick
{
    CGFloat currentPost = self.contentOffset.x + self.frame.size.width/2.f;
    
    // compute the index of the sticky item
    NSInteger stickyIndex = 0;
    for (NSArray* item in self.items)
    {
        CGFloat stickyLimit = [[item objectAtIndex:ITEM_STICKY_LIMIT] floatValue];
        if (currentPost < stickyLimit)
            break;
        
        stickyIndex++;
    }
    
    NSLog(@"stickyIndex %d", stickyIndex);
    
    CGFloat stickyPos = [[[self.items objectAtIndex:stickyIndex] objectAtIndex:ITEM_STICKY_POS] floatValue];
    
    // translate the stickyPos, for the scrollview position reference
    stickyPos -= self.frame.size.width/2.f;
    
    // make the scrollview goes to the sticky position
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.33];
//    self.contentOffset = CGPointMake(stickyPos, self.contentOffset.y);
//    [UIView commitAnimations];
    [self setContentOffset: CGPointMake(stickyPos, self.contentOffset.y) animated:YES];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"%.2f", self.contentOffset.x);
//    
//    NSInteger i =0;
//    for (NSArray* item in self.items)
//    {
//    CGFloat stickyPos = [[item objectAtIndex:ITEM_STICKY_POS] floatValue];
//
//    NSLog(@"sticky [%d] : %.2f", i, stickyPos);
//        i++;
//    }

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





// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // add selector visual indicator
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"WheelSelector.indicator" retainStylesheet:YES overwriteStylesheet:NO error:nil];
////        UIImageView* indicator = [sheet makeImage];
//    UIImage* indicator = [sheet image];
//        CGRect frame = CGRectMake(self.frame.size.width/2.f - indicator.size.width/2.f, self.frame.size.height - indicator.size.height, indicator.size.width, indicator.size.height);
////        
////        
////        
////        [self addSubview:indicator];
//    
//    
//    [indicator drawInRect:frame];
//}


@end
