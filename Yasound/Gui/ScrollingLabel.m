//
//  ScrollingLabel.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 06/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ScrollingLabel.h"
#import "Theme.h"


@implementation ScrollingLabel


#define TIMER_PERIOD 0.01
#define HEIGHT 16
#define ADDITIONAL_SPACE 20



@synthesize labels = _labels;
@synthesize labelFlags = _labelFlags;
@synthesize text = _text;
@synthesize style = _style;
@synthesize font;


- (id)initWithStyle:(NSString*)style
{
    if (self = [super init])
    {
        _labels = [[NSMutableArray alloc] init];
        _labelFlags = [[NSMutableArray alloc] init];
        
        self.style = style;
        
        self.clipsToBounds = YES;
    }
    
    return self;
}


- (void)dealloc
{
    [super dealloc];
}


- (void)setStyle:(NSString *)style
{
    _style = style;

    BundleStylesheet* stylesheet = [[Theme theme] stylesheetForKey:_style retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.font = [stylesheet makeFont];
}


// overload text setter
- (void)setText:(NSString *)text
{
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer =  nil;
        
        [self.labels removeAllObjects];
        [self.labelFlags removeAllObjects];
    }
    
    _text = text;
    
    [self addLabelAtPosition:0];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_PERIOD target:self selector:@selector(onTimerTick:) userInfo:nil repeats:YES];
}




- (void)addLabelAtPosition:(CGFloat)posx
{
    BundleStylesheet* stylesheet = [[Theme theme] stylesheetForKey:self.style retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [stylesheet makeLabel];
    
    // compute the size of the text
    CGSize suggestedSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(FLT_MAX, HEIGHT) lineBreakMode:UILineBreakModeClip];
    
    CGRect frame = CGRectMake(posx, 0, suggestedSize.width +ADDITIONAL_SPACE, HEIGHT);
    label.frame = frame;
    label.text = self.text;
    
    [self.labels addObject:label];
    [self.labelFlags addObject:[NSNumber numberWithBool:NO]];
    
    [self addSubview:label];
}


- (void)onTimerTick:(NSTimer*)timer
{
    NSInteger removeIndex = -1;
    BOOL addLabel = NO;
    
    for (int index = 0; index < self.labels.count; index++)
    {
        UILabel* label = [self.labels objectAtIndex:index];
        
        CGFloat posx = label.frame.origin.x;
        
        // label is entirely out of the bounds => remove it
        if ((posx + label.frame.size.width) <= 0)
        {
            removeIndex = index;
            continue;
        }
        
        // create another label when it's proper time
        BOOL flag = [[self.labelFlags objectAtIndex:index] boolValue];
        if (!flag && ((posx + label.frame.size.width) <= ((self.frame.size.width / 3.f) *2.f)))
        {
            addLabel = YES;
            [self.labelFlags replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:YES]];
        }
        
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.5];
//        label.frame = CGRectMake(posx - 10, label.frame.origin.y, label.frame.size.width, label.frame.size.height);
//        [UIView commitAnimations];

        label.frame = CGRectMake(posx - 0.25, label.frame.origin.y, label.frame.size.width, label.frame.size.height);
    }
    
    if (removeIndex >= 0)
    {
        [self.labels removeObjectAtIndex:removeIndex];
        [self.labelFlags removeObjectAtIndex:removeIndex];
    }
    if (addLabel)
        [self addLabelAtPosition:self.frame.size.width];
    
}
    


@end
