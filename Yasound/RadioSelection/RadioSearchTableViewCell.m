//
//  RadioSearchTableViewCell.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioSearchTableViewCell.h"
#import "Theme.h"
#import "YasoundDataCache.h"
#import "TimeProfile.h"

#import <QuartzCore/QuartzCore.h>
#import "InteractiveView.h"
#import "YasoundDataCacheImage.h"
#import "ProfilCellRadio.h"


#define RADIO_OBJECT_RADIO 0
#define RADIO_OBJECT_VIEW 1



@implementation RadioSearchTableViewCell

@synthesize radioObjects;
@synthesize target;
@synthesize action;

#define OFFSET 98

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier radios:(NSArray*)radios target:(id)target action:(SEL)action
{
    if (self = [super initWithFrame:frame reuseIdentifier:cellIdentifier]) 
    {
        BundleStylesheet* sheet;

        self.target = target;
        self.action = action;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.radioObjects = [[NSMutableArray alloc] init];

        CGFloat xOffset = 0;
        
        NSInteger radioIndex = 0;

        for (Radio* radio in radios)
        {
            [self addRadioGui:radio radioIndex:radioIndex xOffset:xOffset];
            radioIndex++;
            xOffset += OFFSET;
        }
        
  }
  return self;
}





- (void)addRadioGui:(Radio*)radio radioIndex:(NSInteger)radioIndex xOffset:(CGFloat)xOffset
{
    ProfilCellRadio* cell = [[ProfilCellRadio alloc] initWithRadio:radio];
    cell.frame = CGRectMake(xOffset, 0, cell.frame.size.width, cell.frame.size.height);
    [self addSubview:cell];
    
    // store objects
    NSMutableArray* objects = [NSMutableArray arrayWithObjects:radio, cell, nil];
    
    [self.radioObjects addObject:objects];
}




- (void)updateWithRadios:(NSArray*)radios target:(id)target action:(SEL)action
{
    if ((self.radioObjects == nil) || (self.radioObjects.count == 0))
        return;
    
    
    //LBDEBUG ICI
#ifdef DEBUG_PROFILE
    [[TimeProfile main] begin:@"updateRadios"];
#endif
    
    NSInteger radioIndex = 0;
    CGFloat xOffset = 0;
    
    for (Radio* radio in radios)
    {
        // there's only one radio on this row. we need another one
        if (self.radioObjects.count <= radioIndex)
        {
            [self addRadioGui:radio radioIndex:radioIndex xOffset:xOffset];
            radioIndex++;
            xOffset += OFFSET;
            continue;
        }

        //LBDEBUG
        assert(radioIndex < self.radioObjects.count);
        
        NSMutableArray* objects = [self.radioObjects objectAtIndex:radioIndex];
        
        // replace radio
        [objects replaceObjectAtIndex:RADIO_OBJECT_RADIO withObject:radio];
        
        // may not be needed, since "objects" is a reference. Check and go back later...
        //[self.radioObjects replaceObjectAtIndex:radioIndex withObject:objects];
        
        
        
        // and update infos and images
        NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:radio.picture];
        
        ProfilCellRadio* view = [objects objectAtIndex:RADIO_OBJECT_VIEW];
        view.radio = radio;
        
        [view.image releaseCache];

        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Search.avatarDummy" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        view.image.image = [sheet image];
        
        view.image.url = imageURL;
        view.text.text = radio.name;

        radioIndex++;
        xOffset += OFFSET;
    }
    
    
    // we had two radios in this row, but we only need one for this update
    if (self.radioObjects.count > radios.count)
    for (NSInteger index = self.radioObjects.count -1; index >= radios.count; index--)
    {
        NSMutableArray* objects = [self.radioObjects objectAtIndex:index];
        
        UIView* container = [objects objectAtIndex:RADIO_OBJECT_VIEW];
        [container removeFromSuperview];
        [container release];
        
        [self.radioObjects removeObjectAtIndex:index];
    }
    

}






- (void)dealloc
{
  [super dealloc];
}


@end
