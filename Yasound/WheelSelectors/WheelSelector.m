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
#import "InteractiveView.h"

@implementation WheelSelector

@synthesize locked;
@synthesize wheelDelegate;
@synthesize items;
@synthesize itemToIndex;
@synthesize needsToStick;
@synthesize tapRegistered;
@synthesize currentIndex;

#define ITEM_TEXT 0
#define ITEM_WIDTH 1
#define ITEM_STICKY_POS 2
#define ITEM_STICKY_LIMIT 3




- (void)initWithTheme:(NSString*)theme
{
    self.needsToStick = NO;
    self.tapRegistered = NO;
    self.locked = NO;
    
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"wheelSelector%@Background.png", theme]]];
    
    // compute selector's options
        self.items = [[NSMutableArray alloc] init];
    self.itemToIndex = [[NSMutableDictionary alloc] init];

    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:[NSString stringWithFormat:@"WheelSelector.%@.label", theme] retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIFont* font = [sheet makeFont];
    
    
    NSInteger numberOfItems = 0;
    // call delegate
    if ([self.wheelDelegate respondsToSelector:@selector(numberOfItemsInWheelSelector:)])
        numberOfItems = [self.wheelDelegate numberOfItemsInWheelSelector:self];
    
    for (NSInteger index = 0; index < numberOfItems; index++)
    {
        NSString* item = [NSString stringWithFormat:@"item %d", index];
        
        // call delegate
        if ([self.wheelDelegate respondsToSelector:@selector(wheelSelector:titleForItem:)])
            item = [self.wheelDelegate wheelSelector:self titleForItem:index];
        
        [self addItem:item withFont:font];
    }
    
    assert(self.items.count > 0);
        
    CGFloat W2 = (self.frame.size.width /2.f);
    
    NSArray* firstItem = [self.items objectAtIndex:0];

    //LBDEBUG
    assert(ITEM_WIDTH < firstItem.count);
    
    CGFloat firstWidth = [[firstItem objectAtIndex:ITEM_WIDTH] floatValue];
    
    CGFloat fw2 = (firstWidth /2.f);
    CGFloat marginLeft = W2 - fw2;
    CGFloat marginRight = (self.frame.size.width /2.f);

    CGFloat x = marginLeft;
        CGFloat y = 0;
        CGFloat h = 32;
        CGFloat spacing = 48;
        CGFloat width = 0;
    
        // add labels for the selector options, and compute the sticky positions for all items
        NSInteger index = 0;
        for (NSMutableArray* item in self.items)
        {
            UILabel* label = [sheet makeLabel];
            
            //LBDEBUG
            assert(ITEM_WIDTH < item.count);

            width = [[item objectAtIndex:ITEM_WIDTH] floatValue];
            
            // set the "sticky" position for this item (<=> the center position)
            CGFloat stickyPos = (x + width /2.f);
            [item addObject:[NSNumber numberWithFloat:stickyPos]];
            
            // set the "sticky" limit for this item (<=> where the influence of the next item begins)
            CGFloat stickyLimit = (x + width + spacing/2.f);
            [item addObject:[NSNumber numberWithFloat:stickyLimit]];
            
            //LBDEBUG
            assert(ITEM_TEXT < item.count);

            label.text = [item objectAtIndex:ITEM_TEXT];
            CGRect frame = CGRectMake(x, y, width, h);
            label.frame = frame;
            
            [self addSubview:label];
            
            // create an interactive view to support "1 tap" gesture
            CGFloat stickyHalfWidth = stickyLimit - stickyPos;
            frame = CGRectMake(stickyPos-stickyHalfWidth, 0, stickyHalfWidth*2.f, self.frame.size.height);
            InteractiveView* button = [[InteractiveView alloc] initWithFrame:frame target:self action:@selector(onInteractiveTouchUp:) withObject:[NSNumber numberWithInteger:index]];
            [button setTargetOnTouchDown:self action:@selector(onInteractiveTouchDown:) withObject:[NSNumber numberWithInteger:index]];
            [self addSubview:button];

            
            x += width;
            x += spacing;
            index++;
        }

    // compute the contents size and set scrollview's behavior
    self.contentSize = CGSizeMake(x - width + marginRight, self.contentSize.height);
    [self setShowsHorizontalScrollIndicator:NO];
    [self setShowsVerticalScrollIndicator:NO];
    self.delegate = self;
    self.decelerationRate = UIScrollViewDecelerationRateFast;

    
    // add visual layer for the selector indicator (the red needle)
    sheet = [[Theme theme] stylesheetForKey:[NSString stringWithFormat:@"WheelSelector.%@.indicator", theme] retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImage* indicatorImage = [sheet image];
    self.indicatorOffset = CGPointMake(self.frame.size.width/2.f - indicatorImage.size.width/2.f, self.frame.size.height - indicatorImage.size.height);
    CGRect indicatorFrame = CGRectMake(self.indicatorOffset.x, self.frame.origin.y + self.indicatorOffset.y, indicatorImage.size.width, indicatorImage.size.height);
    self.indicatorLayer = [CALayer layer];
    self.indicatorLayer.contents = (id)[indicatorImage CGImage];
    self.indicatorLayer.frame = indicatorFrame;
    [[self.superview layer] addSublayer:self.indicatorLayer]; // to superview 'cause it must not scroll

    // add visual layer for the selector's shadow
    sheet = [[Theme theme] stylesheetForKey:[NSString stringWithFormat:@"WheelSelector.%@.shadow", theme] retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImage* shadowImage = [sheet image];
    self.shadowOffset = CGPointMake(0, 0);
    CGRect frame = CGRectMake(self.shadowOffset.x, self.frame.origin.y + self.shadowOffset.y, shadowImage.size.width, shadowImage.size.height);
    self.shadowLayer = [CALayer layer];
    self.shadowLayer.contents = (id)[shadowImage CGImage];
    self.shadowLayer.frame = frame;
     self.shadowLayer.opaque = NO;
    [[self.superview layer] addSublayer:self.shadowLayer]; // to superview 'cause it must not scroll
    
    // call delegate
    NSInteger initIndex = 0;
    if ([self.wheelDelegate respondsToSelector:@selector(initIndexForWheelSelector:)])
    {
        initIndex = [self.wheelDelegate initIndexForWheelSelector:self];
        [self stickToItem:initIndex silent:NO];
    }
}


- (void)addItem:(NSString*)item  withFont:(UIFont*)font
{
    CGSize suggestedSize = [item sizeWithFont:font constrainedToSize:CGSizeMake(FLT_MAX, 32) lineBreakMode:UILineBreakModeClip];

    [self.items addObject:[NSMutableArray arrayWithObjects:item, [NSNumber numberWithFloat:suggestedSize.width], nil]];
    [self.itemToIndex setObject:[NSNumber numberWithInteger:self.items.count] forKey:item];
}





#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.tapRegistered = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.needsToStick = decelerate;
    if (decelerate)
        return;
    
    NSInteger stickyIndex = [self currentStickyIndex];
    [self stickToItem:stickyIndex silent:NO];
}



- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!self.needsToStick)
        return;
    
    self.needsToStick = NO;

    NSInteger stickyIndex = [self currentStickyIndex];
    [self stickToItem:stickyIndex silent:NO];
}

- (NSInteger)currentStickyIndex
{
    CGFloat currentPost = self.contentOffset.x + self.frame.size.width/2.f;
    
    // compute the index of the sticky item
    NSInteger stickyIndex = 0;
    for (NSArray* item in self.items)
    {
        //LBDEBUG
        assert(ITEM_STICKY_LIMIT < item.count);

        CGFloat stickyLimit = [[item objectAtIndex:ITEM_STICKY_LIMIT] floatValue];
        if (currentPost < stickyLimit)
            break;
        
        stickyIndex++;
    }
    
    return stickyIndex;
}


- (void)stickToItem:(NSInteger)itemIndex silent:(BOOL)silent
{
    if (itemIndex >= self.items.count)
        return;

    //LBDEBUG
    assert(self.items.count > itemIndex);

    NSArray* item = [self.items objectAtIndex:itemIndex];
    
    //LBDEBUG
    assert(ITEM_STICKY_POS < item.count);

    CGFloat stickyPos = [[item objectAtIndex:ITEM_STICKY_POS] floatValue];
    
    // translate the stickyPos, for the scrollview position reference
    stickyPos -= self.frame.size.width/2.f;

    [self setContentOffset: CGPointMake(stickyPos, self.contentOffset.y) animated:YES];
    
    self.currentIndex = itemIndex;
    
    if (silent)
        return;
    
    // send signal to delegate
    if ([self.wheelDelegate respondsToSelector:@selector(wheelSelector:didSelectItemAtIndex:)])
        [self.wheelDelegate wheelSelector:self didSelectItemAtIndex:itemIndex];
}




#pragma mark - InteractiveView selectors

- (void)onInteractiveTouchDown:(NSNumber*)object
{
    self.tapRegistered = YES;
}

- (void)onInteractiveTouchUp:(NSNumber*)object
{
    if (!self.tapRegistered)
        return;
    
    NSInteger index = [object integerValue];
    NSLog(@"onInteractiveTouchUp  index %d", index);
    [self stickToItem:index silent:NO];
}


- (void)setLocked:(BOOL)set
{
    [self setScrollEnabled:!set];
}





@end
