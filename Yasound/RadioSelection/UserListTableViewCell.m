//
//  UserListTableViewCell.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "UserListTableViewCell.h"
#import "Theme.h"
#import "YasoundDataCache.h"
#import "TimeProfile.h"

#import <QuartzCore/QuartzCore.h>
#import "InteractiveView.h"



#define OBJECT_USER 0
#define OBJECT_IMAGE 1
#define OBJECT_MASK 2
#define OBJECT_NAME 4
#define OBJECT_INTERACTIVE_VIEW 5



@implementation UserListTableViewCell

@synthesize objects;
@synthesize target;
@synthesize action;

#define USER_IMAGE_SIZE 118.f

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier users:(NSArray*)users delay:(CGFloat)delay target:(id)target action:(SEL)action
{
    if (self = [super initWithFrame:frame reuseIdentifier:cellIdentifier]) 
    {
        BundleStylesheet* sheet;
          
        self.target = target;
        self.action = action;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.objects = [[NSMutableArray alloc] init];

        CGFloat xOffset = 0;
        
        NSInteger userIndex = 0;

        for (User* user in users)
        {
            
            BundleStylesheet* sheetContainer = [[Theme theme] stylesheetForKey:@"Users.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            sheetContainer.frame = CGRectMake(sheetContainer.frame.origin.x + xOffset, sheetContainer.frame.origin.y, sheetContainer.frame.size.width, sheetContainer.frame.size.height);
            UIView* container = [[UIView alloc] initWithFrame:sheetContainer.frame];
            [self addSubview:container];
            
            // user image
            sheet = [[Theme theme] stylesheetForKey:@"Users.image" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:user.picture];
            WebImageView* userImage = [[WebImageView alloc] initWithImageAtURL:imageURL];
            userImage.frame = sheet.frame;
            [container addSubview:userImage];

            // draw circle mask
            userImage.layer.masksToBounds = YES;
            userImage.layer.cornerRadius = USER_IMAGE_SIZE / 2.f;

            // user mask
            sheet = [[Theme theme] stylesheetForKey:@"Users.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            sheet.frame = CGRectMake(0, 0, sheet.frame.size.width, sheet.frame.size.height);
            UIImageView* userMask = [sheet makeImage];
            [container addSubview:userMask];
            
            
            // name
            sheet = [[Theme theme] stylesheetForKey:@"Users.name"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
            UILabel* name = [sheet makeLabel];
            name.text = user.name;
            [container addSubview:name];

            
            // interactive view : catch the "press down" and "press up" actions
            InteractiveView* interactiveView = [[InteractiveView alloc] initWithFrame:sheetContainer.frame target:self action:@selector(onInteractivePressedUp:) withObject:[NSNumber numberWithInteger:userIndex]];
            [interactiveView setTargetOnTouchDown:self action:@selector(onInteractivePressedDown:) withObject:[NSNumber numberWithInteger:userIndex]];
            [container addSubview:interactiveView];
            
            
            // store objects
            NSMutableArray* objects = [NSMutableArray arrayWithObjects:user, userImage, userMask, name, interactiveView, nil];
            userIndex++;
            
            
            [self.objects addObject:objects];
            
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






- (void)willMoveToSuperview:(UIView *)newSuperview 
{
    [super willMoveToSuperview:newSuperview];
    if(!newSuperview) 
    {
        for (NSArray* objects in self.objects)
        {
            WebImageView* view = [objects objectAtIndex:OBJECT_IMAGE];
            if (view)
                [view releaseCache];
        }
    }
}




- (void)updateWithUsers:(NSArray*)users target:(id)target action:(SEL)action
{
    NSInteger userIndex = 0;
    for (User* user in users)
    {
        NSMutableArray* objects = [self.objects objectAtIndex:userIndex];
        
        // replace radio
        [objects replaceObjectAtIndex:OBJECT_USER withObject:user];
        
        // may not be needed, since "objects" is a reference. Check and go back later...
        //[self.radioObjects replaceObjectAtIndex:radioIndex withObject:objects];
        
        // and update infos and images
        NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:user.picture];
        WebImageView* view = [objects objectAtIndex:OBJECT_IMAGE];
        [view setUrl:imageURL];

        UILabel* label = [objects objectAtIndex:OBJECT_NAME];
        label.text = user.name;

        userIndex++;
    }
}






- (void)dealloc
{
  [super dealloc];
}



- (void)onInteractivePressedDown:(NSNumber*)indexNb
{
    // set the "highlighted" image for the user mask
    NSInteger userIndex = [indexNb integerValue];
    NSArray* objects = [self.objects objectAtIndex:userIndex];
    UIImageView* userMask = [objects objectAtIndex:OBJECT_MASK];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Users.maskHighlighted" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    [userMask setImage:[sheet image]];
}

- (void)onInteractivePressedUp:(NSNumber*)indexNb
{
    // set back the "normal" image for the user mask
    NSInteger userIndex = [indexNb integerValue];
    NSArray* objects = [self.objects objectAtIndex:userIndex];
    UIImageView* userMask = [objects objectAtIndex:OBJECT_MASK];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Users.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    [userMask setImage:[sheet image]];
    
    User* user = [objects objectAtIndex:OBJECT_USER];

    // and call external action to delegate the radio selection
    [self.target performSelector:self.action withObject:user];
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
