//
//  WheelSelectorGenre.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 19/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "WheelSelectorGenre.h"

@implementation WheelSelectorGenre


- (id)init {
    
    if (self = [super init]) {
        
        NSDictionary* resources = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Resources"];
        self.genres = [resources objectForKey:@"styles"];
        assert(self.genres != nil);
        
        self.wheelDelegate = self;
        self.frame = CGRectMake(0, -44, 320, 44);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
//        [self initWithTheme:@"Genre"];
        self.status = eGenreStatusClosed;
    }
    
    return self;
}



- (void)moveTo:(CGFloat)posY {
    
//    self.frame = CGRectMake(self.frame.origin.x, posY, self.frame.size.width, self.frame.size.height);
    self.layer.frame = CGRectMake(self.frame.origin.x, posY, self.frame.size.width, self.frame.size.height);
//    self.shadowLayer.frame = CGRectMake(self.shadowLayer.frame.origin.x, posY + self.shadowOffsetY, self.shadowLayer.frame.size.width, self.shadowLayer.frame.size.height);
//    self.indicatorLayer.frame = CGRectMake(self.indicatorLayer.frame.origin.x, posY + self.indicatorOffsetY, self.indicatorLayer.frame.size.width, self.indicatorLayer.frame.size.height);
//    self.shadowLayer.position = CGPointMake(self.shadowLayer.bounds.origin.x, posY + self.shadowOffsetY);
//    self.indicatorLayer.position = CGPointMake(self.indicatorLayer.bounds.origin.x, posY + self.indicatorOffsetY);
    
    [CATransaction begin];
    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    
//    NSLog(@"%.2f", self.shadowOffset.x);
    self.shadowLayer.anchorPoint = CGPointMake(0, 0);
    self.indicatorLayer.anchorPoint = CGPointMake(0, 0);
    
    self.shadowLayer.position = CGPointMake(self.shadowOffset.x, posY + self.shadowOffset.y);
    self.indicatorLayer.position = CGPointMake(self.indicatorOffset.x, posY + self.indicatorOffset.y);
    [CATransaction commit];
    
//    [self.shadowLayer setNeedsDisplay];
//    [self.indicatorLayer setNeedsDisplay];
}





#pragma mark - WheelSelectorDelegate

- (NSInteger)numberOfItemsInWheelSelector:(WheelSelector*)wheel
{
    if (self.genres == nil)
        return 0;
    return self.genres.count;
}

- (NSString*)wheelSelector:(WheelSelector*)wheel titleForItem:(NSInteger)itemIndex
{
    NSString* genre = [self.genres objectAtIndex:itemIndex];
    NSString* title = NSLocalizedString(genre, nil);
    return title;
}

- (NSInteger)initIndexForWheelSelector:(WheelSelector*)wheel
{
    return 0;
}




- (void)wheelSelector:(WheelSelector*)wheel didSelectItemAtIndex:(NSInteger)itemIndex
{
    
    
}



@end