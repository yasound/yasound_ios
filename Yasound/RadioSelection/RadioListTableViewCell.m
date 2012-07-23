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


//@interface RadioListTableViewCell (internal_update)
//
//- (void)onUpdate:(NSTimer*)timer;
//
//@end

#define RADIO_OBJECT_RADIO 0
#define RADIO_OBJECT_IMAGE 1
#define RADIO_OBJECT_MASK 2
#define RADIO_OBJECT_USER_IMAGE 3
#define RADIO_OBJECT_TITLE 4
#define RADIO_OBJECT_SUBSCRIBERS 5
#define RADIO_OBJECT_LISTENERS 6
#define RADIO_OBJECT_INTERACTIVE_VIEW 7



@implementation RadioListTableViewCell

@synthesize radioObjects;
@synthesize target;
@synthesize action;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier radios:(NSArray*)radios target:(id)target action:(SEL)action
{
    if (self = [super initWithFrame:frame reuseIdentifier:cellIdentifier]) 
    {
        BundleStylesheet* sheet;
        NSError* error;
          
        self.target = target;
        self.action = action;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.radioObjects = [[NSMutableArray alloc] init];

        CGFloat xOffset = 0;
        
        NSInteger radioIndex = 0;

        for (Radio* radio in radios)
        {
            
            BundleStylesheet* sheetContainer = [[Theme theme] stylesheetForKey:@"Radios.mask" retainStylesheet:YES overwriteStylesheet:NO error:&error];
            sheetContainer.frame = CGRectMake(sheetContainer.frame.origin.x + xOffset, sheetContainer.frame.origin.y, sheetContainer.frame.size.width, sheetContainer.frame.size.height);
            UIView* container = [[UIView alloc] initWithFrame:sheetContainer.frame];
            [self addSubview:container];
            
            // radio image
            sheet = [[Theme theme] stylesheetForKey:@"Radios.image" retainStylesheet:YES overwriteStylesheet:NO error:&error];
            NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:radio.picture];
            WebImageView* radioImage = [[WebImageView alloc] initWithImageAtURL:imageURL];
            radioImage.frame = sheet.frame;
            [container addSubview:radioImage];

            // radio mask
            sheet = [[Theme theme] stylesheetForKey:@"Radios.mask" retainStylesheet:YES overwriteStylesheet:NO error:&error];
            sheet.frame = CGRectMake(0, 0, sheet.frame.size.width, sheet.frame.size.height);
            UIImageView* radioMask = [sheet makeImage];
            [container addSubview:radioMask];
            
            // user picture
            sheet = [[Theme theme] stylesheetForKey:@"Radios.userImage" retainStylesheet:YES overwriteStylesheet:NO error:&error];
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
            sheet = [[Theme theme] stylesheetForKey:@"Radios.title"  retainStylesheet:YES overwriteStylesheet:NO error:&error];
            UILabel* title = [sheet makeLabel];
            title.text = radio.name;
            [container addSubview:title];

            // subscribers icon
            sheet = [[Theme theme] stylesheetForKey:@"Radios.subscribersIcon" retainStylesheet:YES overwriteStylesheet:NO error:&error];
            UIImageView* icon = [sheet makeImage];
            [container addSubview:icon];
            
            // subscribers label
            sheet = [[Theme theme] stylesheetForKey:@"Radios.subscribers"  retainStylesheet:YES overwriteStylesheet:NO error:&error];
            UILabel* subscribers = [sheet makeLabel];
            subscribers.text = [NSString stringWithFormat:@"%d", [radio.favorites integerValue]];
            [container addSubview:subscribers];
            

            // listeners icon
            sheet = [[Theme theme] stylesheetForKey:@"Radios.listenersIcon" retainStylesheet:YES overwriteStylesheet:NO error:&error];
            icon = [sheet makeImage];
            [container addSubview:icon];

            // listeners label
            sheet = [[Theme theme] stylesheetForKey:@"Radios.listeners"  retainStylesheet:YES overwriteStylesheet:NO error:&error];
            UILabel* listeners = [sheet makeLabel];
            listeners.text = [NSString stringWithFormat:@"%d", [radio.nb_current_users integerValue]];
            [container addSubview:listeners];
            
            // interactive view : catch the "press down" and "press up" actions
            InteractiveView* interactiveView = [[InteractiveView alloc] initWithFrame:sheetContainer.frame target:self action:@selector(onInteractivePressedUp:) withObject:[NSNumber numberWithInteger:radioIndex]];
            [interactiveView setTargetOnTouchDown:self action:@selector(onInteractivePressedDown:) withObject:[NSNumber numberWithInteger:radioIndex]];
            [container addSubview:interactiveView];
            
            
            // store objects
            NSMutableArray* objects = [NSMutableArray arrayWithObjects:radio, radioImage, radioMask, userImage, title, subscribers, listeners, interactiveView, nil];
            radioIndex++;
            
            
            
            
            
            [self.radioObjects addObject:objects];
            
            xOffset += (self.frame.size.width / 2.f);
        }

            
  }
  return self;
}






- (void)willMoveToSuperview:(UIView *)newSuperview 
{
    [super willMoveToSuperview:newSuperview];
    if(!newSuperview) 
    {
        for (NSArray* objects in self.radioObjects)
        {
            WebImageView* view = [objects objectAtIndex:RADIO_OBJECT_IMAGE];
            if (view)
                [view releaseCache];
            view = [objects objectAtIndex:RADIO_OBJECT_USER_IMAGE];
            if (view)
                [view releaseCache];
        }
    }
}




- (void)updateWithRadios:(NSArray*)radios target:(id)target action:(SEL)action
{
    NSInteger radioIndex = 0;
    for (Radio* radio in radios)
    {
        NSMutableArray* objects = [self.radioObjects objectAtIndex:radioIndex];
        
        // replace radio
        [objects replaceObjectAtIndex:RADIO_OBJECT_RADIO withObject:radio];
        
        // may not be needed, since "objects" is a reference. Check and go back later...
        //[self.radioObjects replaceObjectAtIndex:radioIndex withObject:objects];
        
        // and update infos and images
        NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:radio.picture];
        WebImageView* view = [objects objectAtIndex:RADIO_OBJECT_IMAGE];
        [view setUrl:imageURL];

        imageURL = [[YasoundDataProvider main] urlForPicture:radio.creator.picture];
        view = [objects objectAtIndex:RADIO_OBJECT_USER_IMAGE];
        [view setUrl:imageURL];

        UILabel* label = [objects objectAtIndex:RADIO_OBJECT_TITLE];
        label.text = radio.name;

        label = [objects objectAtIndex:RADIO_OBJECT_SUBSCRIBERS];
        label.text = [NSString stringWithFormat:@"%d", [radio.favorites integerValue]];
        
        label = [objects objectAtIndex:RADIO_OBJECT_LISTENERS];
        label.text = [NSString stringWithFormat:@"%d", [radio.nb_current_users integerValue]];
        
        radioIndex++;
    }
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
    
    Radio* radio = [objects objectAtIndex:RADIO_OBJECT_RADIO];

    // and call external action to delegate the radio selection
    [self.target performSelector:self.action withObject:radio];
}





//- (void)onUpdate:(NSTimer*)timer
//{
//    [[YasoundDataCache main] requestCurrentSongForRadio:self.radio target:self action:@selector(receivedCurrentSong:withInfo:)];
//}
//- (void)receivedCurrentSong:(Song*)song withInfo:(NSDictionary*)info
//{
//    if (!song)
//        return;
//    
//    self.radioSubtitle1.text = song.artist;
//    self.radioSubtitle2.text = song.name;
//}



//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//  [super setSelected:selected animated:animated];
//
//  if (selected)
//  {
////    self.cellBackground.image = _bkgSelected;
////    self.radioAvatarMask.image = _maskSelected;
//   
////    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionTitle" error:nil];
////    [sheet applyToLabel:self.radioTitle class:@"selected"];
////
////    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionSubtitle1" error:nil];
////    [sheet applyToLabel:self.radioSubtitle1 class:@"selected"];
////
////    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionSubtitle2" error:nil];
////    [sheet applyToLabel:self.radioSubtitle2 class:@"selected"];
////
////    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionLikes" error:nil];
////    [sheet applyToLabel:self.radioLikes class:@"selected"];
////
////    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionListeners" error:nil];
////    [sheet applyToLabel:self.radioListeners class:@"selected"];
//  }
//  else
//  {
////    self.cellBackground.image = _bkgBackup;
////    self.radioAvatarMask.image = _maskBackup;
//
////    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionTitle" error:nil];
////    [sheet applyToLabel:self.radioTitle class:nil];
////    
////    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionSubtitle1" error:nil];
////    [sheet applyToLabel:self.radioSubtitle1 class:nil];
////    
////    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionSubtitle2" error:nil];
////    [sheet applyToLabel:self.radioSubtitle2 class:nil];
////    
////    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionLikes" error:nil];
////    [sheet applyToLabel:self.radioLikes class:nil];
////    
////    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionListeners" error:nil];
////    [sheet applyToLabel:self.radioListeners class:nil];
//  }
//}

@end
