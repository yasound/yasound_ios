//
//  WheelSelectorGenre.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 19/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "WheelSelectorGenre.h"
#import "RootViewController.h"
#import "Genres.h"


@implementation WheelSelectorGenre


- (id)init {
    
    if (self = [super init]) {
        
        self.genres = [Genres genres];
        assert(self.genres != nil);
        
        self.wheelDelegate = self;
        self.frame = CGRectMake(0, -44, 320, 44);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.status = eGenreStatusClosed;
    }
    
    return self;
}



- (void)moveTo:(CGFloat)posY {
    
    self.frame = CGRectMake(self.frame.origin.x, posY, self.frame.size.width, self.frame.size.height);
    
    [CATransaction begin];
    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];

    self.shadowLayer.anchorPoint = CGPointMake(0, 0);
    self.indicatorLayer.anchorPoint = CGPointMake(0, 0);
    self.shadowLayer.position = CGPointMake(self.shadowOffset.x, posY + self.shadowOffset.y);
    self.indicatorLayer.position = CGPointMake(self.indicatorOffset.x, posY + self.indicatorOffset.y);
    
    [CATransaction commit];
}


- (void)moveTo:(CGFloat)posY animated:(BOOL)animated {
    
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.33];
    }
    
    self.layer.frame = CGRectMake(self.frame.origin.x, posY, self.frame.size.width, self.frame.size.height);
    
    if (animated) {
        [UIView commitAnimations];
    }


        [CATransaction begin];
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    
    self.shadowLayer.anchorPoint = CGPointMake(0, 0);
    self.indicatorLayer.anchorPoint = CGPointMake(0, 0);
    self.shadowLayer.position = CGPointMake(self.shadowOffset.x, posY + self.shadowOffset.y);
    self.indicatorLayer.position = CGPointMake(self.indicatorOffset.x, posY + self.indicatorOffset.y);
    
        [CATransaction commit];
}



- (void)open {

    [self moveTo:0];
}

- (void)close {
    
    [self moveTo:-self.frame.size.height animated:YES];
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



- (void)wheelSelector:(WheelSelector*)wheel didSelectItemAtIndex:(NSInteger)itemIndex
{
    NSString* genre = [self.genres objectAtIndex:itemIndex];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GENRE_SELECTED object:genre];
}



@end