//
//  RadioListTableViewCell.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioListTableViewCell.h"
#import "Theme.h"
#import "YasoundDataCache.h"
#import "TimeProfile.h"

#import <QuartzCore/QuartzCore.h>
#import "InteractiveView.h"
#import "YasoundDataCacheImage.h"



#define RADIO_OBJECT_RADIO 0
#define RADIO_OBJECT_IMAGE 1
#define RADIO_OBJECT_MASK 2
#define RADIO_OBJECT_USER_IMAGE 3
#define RADIO_OBJECT_TITLE 4
#define RADIO_OBJECT_SUBSCRIBERS 5
#define RADIO_OBJECT_LISTENERS 6
#define RADIO_OBJECT_INTERACTIVE_VIEW 7
#define RADIO_OBJECT_CONTAINER 8
#define RADIO_OBJECT_RANK 9



@implementation RadioListTableViewCell

@synthesize radioObjects;
@synthesize target;
@synthesize action;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier radios:(NSArray*)radios delay:(CGFloat)delay target:(id)aTarget action:(SEL)action showRank:(BOOL)showRank
{
    if (self = [super initWithFrame:frame reuseIdentifier:cellIdentifier]) 
    {
        _showRank = showRank;
        self.target = aTarget;
        self.action = action;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.radioObjects = [[NSMutableArray alloc] init];

        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Radios.rowBackground" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIImageView* rowBackground = [sheet makeImage];
        [self addSubview:rowBackground];
        
        CGFloat xOffset = 0;
        
        NSInteger radioIndex = 0;

        for (YaRadio* radio in radios)
        {
            [self addRadioGui:radio radioIndex:radioIndex xOffset:xOffset];
            radioIndex++;
            xOffset += (self.frame.size.width / 2.f);
        }
        
        if (delay)
        {
            self.alpha = 0;
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:delay];
            self.alpha = 1;
            [UIView commitAnimations];
            
            delay += 0.15;
        }

            
  }
  return self;
}





- (void)addRadioGui:(YaRadio*)radio radioIndex:(NSInteger)radioIndex xOffset:(CGFloat)xOffset
{
    BundleStylesheet* sheetContainer = [[Theme theme] stylesheetForKey:@"Radios.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    sheetContainer.frame = CGRectMake(sheetContainer.frame.origin.x + xOffset, sheetContainer.frame.origin.y, sheetContainer.frame.size.width, sheetContainer.frame.size.height);
    UIView* container = [[UIView alloc] initWithFrame:sheetContainer.frame];
    [self addSubview:container];
    
    // radio image
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Radios.image" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:radio.picture];
    WebImageView* radioImage = [[WebImageView alloc] initWithImageAtURL:imageURL];
    radioImage.frame = sheet.frame;
    [container addSubview:radioImage];
    
    // radio mask
    sheet = [[Theme theme] stylesheetForKey:@"Radios.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    sheet.frame = CGRectMake(0, 0, sheet.frame.size.width, sheet.frame.size.height);
    UIImageView* radioMask = [sheet makeImage];
    [container addSubview:radioMask];
    
    // user picture
    sheet = [[Theme theme] stylesheetForKey:@"Radios.userImage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    imageURL = [[YasoundDataProvider main] urlForPicture:radio.creator.picture];
    WebImageView* userImage = [[WebImageView alloc] initWithImageAtURL:imageURL];
    userImage.frame = sheet.frame;
    [container addSubview:userImage];
    
    // draw circle mask
    userImage.layer.masksToBounds = YES;
    userImage.layer.cornerRadius = 16.5;
    
    // avatar circled mask
    sheet = [[Theme theme] stylesheetForKey:@"Radios.userMask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImageView* userMask = [sheet makeImage];
    [container addSubview:userMask];
    
    
    // title
    sheet = [[Theme theme] stylesheetForKey:@"Radios.title"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* title = [sheet makeLabel];
    title.text = radio.name;
    [container addSubview:title];
    
    // subscribers icon
    sheet = [[Theme theme] stylesheetForKey:@"Radios.subscribersIcon" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImageView* icon = [sheet makeImage];
    [container addSubview:icon];
    
    // subscribers label
    sheet = [[Theme theme] stylesheetForKey:@"Radios.subscribers"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* subscribers = [sheet makeLabel];
    subscribers.text = [NSString stringWithFormat:@"%d", [radio.favorites integerValue]];
    [container addSubview:subscribers];
    
    
    // listeners icon
    sheet = [[Theme theme] stylesheetForKey:@"Radios.listenersIcon" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    icon = [sheet makeImage];
    [container addSubview:icon];
    
    // listeners label
    sheet = [[Theme theme] stylesheetForKey:@"Radios.listeners"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* listeners = [sheet makeLabel];
    listeners.text = [NSString stringWithFormat:@"%d", [radio.nb_current_users integerValue]];
    [container addSubview:listeners];
    
    // interactive view : catch the "press down" and "press up" actions
    InteractiveView* interactiveView = [[InteractiveView alloc] initWithFrame:sheetContainer.frame target:self action:@selector(onInteractivePressedUp:) withObject:[NSNumber numberWithInteger:radioIndex]];
    [interactiveView setTargetOnTouchDown:self action:@selector(onInteractivePressedDown:) withObject:[NSNumber numberWithInteger:radioIndex]];
    [container addSubview:interactiveView];
    
    //
    sheet = [[Theme theme] stylesheetForKey:@"Radios.rank"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* rank = [sheet makeLabel];
    
    if (_showRank) {
        
        sheet = [[Theme theme] stylesheetForKey:@"Radios.rankBackground" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIImageView* rankBackground = [sheet makeImage];
        [container addSubview:rankBackground];

        rank.adjustsFontSizeToFitWidth = YES;
        [rankBackground addSubview:rank];
        rank.text = [NSString stringWithFormat:@"%d", [radio assignedTopRank]];
    }
    
    // store objects
    NSMutableArray* objects = [NSMutableArray arrayWithObjects:radio, radioImage, radioMask, userImage, title, subscribers, listeners, interactiveView, container, rank, nil];
    
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
    
    for (YaRadio* radio in radios)
    {
        // there's only one radio on this row. we need another one
        if (self.radioObjects.count <= radioIndex)
        {
            [self addRadioGui:radio radioIndex:radioIndex xOffset:xOffset];
            radioIndex++;
            xOffset += (self.frame.size.width / 2.f);
            continue;
        }

        
        NSMutableArray* objects = [self.radioObjects objectAtIndex:radioIndex];
        
        // replace radio
        [objects replaceObjectAtIndex:RADIO_OBJECT_RADIO withObject:radio];
        
        // may not be needed, since "objects" is a reference. Check and go back later...
        //[self.radioObjects replaceObjectAtIndex:radioIndex withObject:objects];
        

        
        
        WebImageView* view = [objects objectAtIndex:RADIO_OBJECT_IMAGE];
        assert(view);
        assert([view isKindOfClass:[WebImageView class]]);
        [view releaseCache];

        
        // and update infos and images
        NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:radio.picture];
        
        
  
        [view setUrl:imageURL];

        view = [objects objectAtIndex:RADIO_OBJECT_USER_IMAGE];
        assert(view);
        assert([view isKindOfClass:[WebImageView class]]);
        [view releaseCache];

        imageURL = [[YasoundDataProvider main] urlForPicture:radio.creator.picture];
        [view setUrl:imageURL];

        
        
        UILabel* label = [objects objectAtIndex:RADIO_OBJECT_TITLE];
        label.text = radio.name;

        label = [objects objectAtIndex:RADIO_OBJECT_SUBSCRIBERS];
        label.text = [NSString stringWithFormat:@"%d", [radio.favorites integerValue]];
        
        label = [objects objectAtIndex:RADIO_OBJECT_LISTENERS];
        label.text = [NSString stringWithFormat:@"%d", [radio.nb_current_users integerValue]];
        
        if (_showRank) {
            label = [objects objectAtIndex:RADIO_OBJECT_RANK];
            label.text = [NSString stringWithFormat:@"%d", [radio assignedTopRank]];
        }

        
        radioIndex++;
        xOffset += (self.frame.size.width / 2.f);
    }
    
    
    // we had two radios in this row, but we only need one for this update
    if (self.radioObjects.count > radios.count)
    {
        NSMutableArray* objects = [self.radioObjects objectAtIndex:1];
        
        UIView* container = [objects objectAtIndex:RADIO_OBJECT_CONTAINER];
        [container removeFromSuperview];
        [container release];
        
//        Radio* radio = [objects objectAtIndex:RADIO_OBJECT_RADIO];
//        [radio release];
        
        [self.radioObjects removeObjectAtIndex:1];
    }
    
#ifdef DEBUG_PROFILE
    //LBDEBUG ICI
    [[TimeProfile main] end:@"updateRadios"];
    [[TimeProfile main] logAverageInterval:@"updateRadios" inMilliseconds:YES];
#endif



}






- (void)dealloc
{
  [super dealloc];
}



- (void)onInteractivePressedDown:(NSNumber*)indexNb
{
    // set the "highlighted" image for the radio mask
    NSInteger radioIndex = [indexNb integerValue];
    NSArray* objects = [self.radioObjects objectAtIndex:radioIndex];
    UIImageView* radioMask = [objects objectAtIndex:RADIO_OBJECT_MASK];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Radios.maskHighlighted" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    [radioMask setImage:[sheet image]];
}

- (void)onInteractivePressedUp:(NSNumber*)indexNb
{
    // set back the "normal" image for the radio mask
    NSInteger radioIndex = [indexNb integerValue];
    NSArray* objects = [self.radioObjects objectAtIndex:radioIndex];
    UIImageView* radioMask = [objects objectAtIndex:RADIO_OBJECT_MASK];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Radios.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    [radioMask setImage:[sheet image]];
    
    YaRadio* radio = [objects objectAtIndex:RADIO_OBJECT_RADIO];

    // and call external action to delegate the radio selection
    [self.target performSelector:self.action withObject:radio];
}




@end
