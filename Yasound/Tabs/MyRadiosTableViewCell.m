//
//  MyRadiosTableViewCell.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "MyRadiosTableViewCell.h"
#import "Theme.h"
#import "YasoundDataProvider.h"


@implementation MyRadiosTableViewCell

@synthesize delegate;
@synthesize radio;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier radio:(Radio*)radio target:(id)target;
{
    if (self = [super initWithFrame:frame reuseIdentifier:cellIdentifier]) 
    {
        BundleStylesheet* sheet;
        self.delegate = target;
        self.radio = radio;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
          
        // radio image
        sheet = [[Theme theme] stylesheetForKey:@"MyRadios.image" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:radio.picture];
        self.image = [[WebImageView alloc] initWithImageAtURL:imageURL];
        self.image.frame = sheet.frame;
        [self addSubview:self.image];

        // radio mask
        sheet = [[Theme theme] stylesheetForKey:@"MyRadios.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        [self addSubview:[sheet makeImage]];
        
        // title
        sheet = [[Theme theme] stylesheetForKey:@"MyRadios.title"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.title = [sheet makeLabel];
        self.title.text = radio.name;
        [self addSubview:self.title];

        // subscribers icon
        sheet = [[Theme theme] stylesheetForKey:@"MyRadios.subscribersIcon" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIImageView* icon = [sheet makeImage];
        [self addSubview:icon];
        
        // subscribers label
        sheet = [[Theme theme] stylesheetForKey:@"MyRadios.subscribers"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.subscribers = [sheet makeLabel];
        self.subscribers.text = [NSString stringWithFormat:@"%d", [radio.favorites integerValue]];
        [self addSubview:self.subscribers];
        

        // listeners icon
        sheet = [[Theme theme] stylesheetForKey:@"MyRadios.listenersIcon" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        [self addSubview:[sheet makeImage]];

        // listeners label
        sheet = [[Theme theme] stylesheetForKey:@"MyRadios.listeners"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.listeners = [sheet makeLabel];
        self.listeners.text = [NSString stringWithFormat:@"%d", [radio.nb_current_users integerValue]];
        [self addSubview:self.listeners];
        
        // metric1 label
        sheet = [[Theme theme] stylesheetForKey:@"MyRadios.metric1.label"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.metric1 = [sheet makeLabel];
        self.metric1.text = @"12345";
        [self addSubview:self.metric1];

        // metric1 sublabel
        sheet = [[Theme theme] stylesheetForKey:@"MyRadios.metric1.sublabel"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UILabel* label = [sheet makeLabel];
        label.text = NSLocalizedString(@"MyRadios.metric1.sublabel", nil);
        [self addSubview:label];

        // metric2 label
        sheet = [[Theme theme] stylesheetForKey:@"MyRadios.metric2.label"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.metric2 = [sheet makeLabel];
        self.metric2.text = @"432";
        [self addSubview:self.metric2];
        
        // metric2 sublabel
        sheet = [[Theme theme] stylesheetForKey:@"MyRadios.metric2.sublabel"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
        label = [sheet makeLabel];
        label.text = NSLocalizedString(@"MyRadios.metric2.sublabel", nil);
        [self addSubview:label];

        // stats button
        
        
        
        
        [self.radioObjects addObject:objects];
        
        xOffset += (self.frame.size.width / 2.f);

            
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
