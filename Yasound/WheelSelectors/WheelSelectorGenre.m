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
        self.frame = CGRectMake(0, 0, 320, 44);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
//        [self initWithTheme:@"Genre"];
        self.status = eGenreStatusClosed;
    }
    
    return self;
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