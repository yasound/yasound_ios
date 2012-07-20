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


//@interface RadioListTableViewCell (internal_update)
//
//- (void)onUpdate:(NSTimer*)timer;
//
//@end

#define RADIO_OBJECT_RADIO 0
#define RADIO_OBJECT_IMAGE 1
#define RADIO_OBJECT_USER_IMAGE 2
#define RADIO_OBJECT_TITLE 3
#define RADIO_OBJECT_SUBSCRIBERS 4
#define RADIO_OBJECT_LISTENERS 5



@implementation RadioListTableViewCell

@synthesize radioObjects;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier radios:(NSArray*)radios
{
    if (self = [super initWithFrame:frame reuseIdentifier:cellIdentifier]) 
    {
        BundleStylesheet* sheet;
        NSError* error;
          
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.radioObjects = [[NSMutableArray alloc] init];

        CGFloat xOffset = 0;

        for (Radio* radio in radios)
        {
            
            BundleStylesheet* sheetMask = [[Theme theme] stylesheetForKey:@"Radios.mask" retainStylesheet:YES overwriteStylesheet:NO error:&error];
            sheetMask.frame = CGRectMake(sheetMask.frame.origin.x + xOffset, sheetMask.frame.origin.y, sheetMask.frame.size.width, sheetMask.frame.size.height);
            UIView* container = [[UIView alloc] initWithFrame:sheetMask.frame];
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
            
            // store objects
            NSMutableArray* objects = [NSMutableArray arrayWithObjects:radio, radioImage, userImage, title, subscribers, listeners, nil];
            
            
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




- (void)updateWithRadios:(NSArray*)radios
{
    NSInteger index = 0;
    for (Radio* radio in radios)
    {
        NSMutableArray* objects = [self.radioObjects objectAtIndex:index];
        
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
        
        index++;
    }
}




- (void)dealloc
{
  [super dealloc];
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
