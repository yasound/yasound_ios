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
#define OBJECT_NAME 3
#define OBJECT_INTERACTIVE_VIEW 4
#define OBJECT_CONTAINER 5



@implementation UserListTableViewCell

@synthesize objects;
@synthesize target;
@synthesize action;

#define USER_IMAGE_SIZE 117.f

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
        NSInteger itemIndex = 0;
        
        for (User* user in users)
        {
            [self addItemGui:user itemIndex:itemIndex xOffset:xOffset];
            itemIndex++;
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

        
        
        
- (void)addItemGui:(User*)user itemIndex:(NSInteger)itemIndex xOffset:(CGFloat)xOffset
{
            
//            BundleStylesheet* sheetContainer = [[Theme theme] stylesheetForKey:@"Users.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//            sheetContainer.frame = CGRectMake(sheetContainer.frame.origin.x + xOffset, sheetContainer.frame.origin.y, sheetContainer.frame.size.width, sheetContainer.frame.size.height);
            BundleStylesheet* sheetContainer = [[Theme theme] stylesheetForKey:@"Users.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    CGRect frame = CGRectMake(xOffset, 0, sheetContainer.frame.size.width, sheetContainer.frame.size.height + 32);
            UIView* container = [[UIView alloc] initWithFrame:frame];
    
    
            [self addSubview:container];

    //LBDEBUG
//    NSLog(@"\n\naddItemGui index %d   xOffset %.2f", itemIndex, xOffset);
//     frame = container.frame;
//    NSLog(@"container %.2f, %.2f  (%.2fx%.2f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
            
            // user image
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Users.image" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:user.picture];
            WebImageView* userImage = [[WebImageView alloc] initWithImageAtURL:imageURL];
            userImage.frame = CGRectMake(sheet.frame.origin.x, sheet.frame.origin.y, sheet.frame.size.width, sheet.frame.size.height);
            [container addSubview:userImage];
    
    
    //LBDEBUG
//     frame = userImage.frame;
//    NSLog(@"userImage %.2f, %.2f  (%.2fx%.2f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);


            // draw circle mask
            userImage.layer.masksToBounds = YES;
            userImage.layer.cornerRadius = USER_IMAGE_SIZE / 2.f;

            // user mask
            sheet = [[Theme theme] stylesheetForKey:@"Users.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            UIImageView* userMask = [sheet makeImage];
//            CGRect maskRect = CGRectMake(sheet.frame.origin.x + xOffset, sheet.frame.origin.y, sheet.frame.size.width, sheet.frame.size.height);
//            userMask.frame = maskRect;

    [container addSubview:userMask];

    
    //LBDEBUG
//    frame = userMask.frame;
//    NSLog(@"userMask %.2f, %.2f  (%.2fx%.2f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);

            
            // name
            sheet = [[Theme theme] stylesheetForKey:@"Users.name"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
            UILabel* name = [sheet makeLabel];
//            name.frame = CGRectMake(name.frame.origin.x + xOffset, name.frame.origin.y, name.frame.size.width, name.frame.size.height);
            name.text = user.name;
            [container addSubview:name];
            
    //LBDEBUG
//    frame = name.frame;
//    NSLog(@"label %.2f, %.2f  (%.2fx%.2f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    
    
//            InteractiveView* interactiveView = nil;
       sheet = [[Theme theme] stylesheetForKey:@"Users.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];

            // interactive view : catch the "press down" and "press up" actions
    InteractiveView* interactiveView0 = [[InteractiveView alloc] initWithFrame:sheet.frame target:self action:@selector(onInteractivePressedUp:) withObject:[NSNumber numberWithInteger:itemIndex]];
//    CGRect frame = CGRectMake(sheet.frame.origin.x + xOffset,sheet.frame.origin.y,sheet.frame.size.width, sheet.frame.size.height);
//    interactiveView0.frame = frame;

            [interactiveView0 setTargetOnTouchDown:self action:@selector(onInteractivePressedDown:) withObject:[NSNumber numberWithInteger:itemIndex]];
            [container addSubview:interactiveView0];

//        InteractiveView* interactiveView1 = [[InteractiveView alloc] initWithFrame:CGRectMake(sheet.frame.origin.x + 160,sheet.frame.origin.y,sheet.frame.size.width,sheet.frame.size.height) target:self action:@selector(onInteractivePressedUp:) withObject:[NSNumber numberWithInteger:1]];
//        [interactiveView1 setTargetOnTouchDown:self action:@selector(onInteractivePressedDown:) withObject:[NSNumber numberWithInteger:1]];
//        [self addSubview:interactiveView1];

    
//    //LBDEBUG
//    frame = interactiveView0.frame;
//    NSLog(@"interactive %.2f, %.2f  (%.2fx%.2f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);

            
            // store objects
            NSMutableArray* objects = [NSMutableArray arrayWithObjects:user, userImage, userMask, name, interactiveView0,container, nil];
            
    assert(objects.count == 6);
            
            [self.objects addObject:objects];
            
//            xOffset += (self.frame.size.width / 2.f);
            
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








//- (void)updateWithRadios:(NSArray*)radios target:(id)target action:(SEL)action
//{
//    if ((self.radioObjects == nil) || (self.radioObjects.count == 0))
//        return;
//    
//    NSInteger radioIndex = 0;
//    CGFloat xOffset = 0;
//    
//    for (Radio* radio in radios)
//    {
//        // there's only one radio on this row. we need another one
//        if (self.radioObjects.count <= radioIndex)
//        {
//            [self addRadioGui:radio radioIndex:radioIndex xOffset:xOffset];
//            radioIndex++;
//            xOffset += (self.frame.size.width / 2.f);
//            continue;
//        }
//        
//        NSMutableArray* objects = [self.radioObjects objectAtIndex:radioIndex];
//        
//        // replace radio
//        [objects replaceObjectAtIndex:RADIO_OBJECT_RADIO withObject:radio];
//        
//        // may not be needed, since "objects" is a reference. Check and go back later...
//        //[self.radioObjects replaceObjectAtIndex:radioIndex withObject:objects];
//        
//        // and update infos and images
//        NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:radio.picture];
//        WebImageView* view = [objects objectAtIndex:RADIO_OBJECT_IMAGE];
//        [view setUrl:imageURL];
//        
//        imageURL = [[YasoundDataProvider main] urlForPicture:radio.creator.picture];
//        view = [objects objectAtIndex:RADIO_OBJECT_USER_IMAGE];
//        [view setUrl:imageURL];
//        
//        UILabel* label = [objects objectAtIndex:RADIO_OBJECT_TITLE];
//        label.text = radio.name;
//        
//        label = [objects objectAtIndex:RADIO_OBJECT_SUBSCRIBERS];
//        label.text = [NSString stringWithFormat:@"%d", [radio.favorites integerValue]];
//        
//        label = [objects objectAtIndex:RADIO_OBJECT_LISTENERS];
//        label.text = [NSString stringWithFormat:@"%d", [radio.nb_current_users integerValue]];
//        
//        radioIndex++;
//        xOffset += (self.frame.size.width / 2.f);
//        
//    }
//    
//    // we had two radios in this row, but we only need one for this update
//    if (self.radioObjects.count > radios.count)
//    {
//        NSMutableArray* objects = [self.radioObjects objectAtIndex:1];
//        
//        UIView* container = [objects objectAtIndex:RADIO_OBJECT_CONTAINER];
//        [container removeFromSuperview];
//        [container release];
//        
//        //        Radio* radio = [objects objectAtIndex:RADIO_OBJECT_RADIO];
//        //        [radio release];
//        
//        [self.radioObjects removeObjectAtIndex:1];
//    }
//}




- (void)updateWithUsers:(NSArray*)users target:(id)target action:(SEL)action
{
    if ((self.objects == nil) || (self.objects.count == 0))
        return;
    
//    NSInteger userIndex = 0;
//    for (User* user in users)
//    {
//        NSMutableArray* objects = [self.objects objectAtIndex:userIndex];
//        
//        // replace radio
//        [objects replaceObjectAtIndex:OBJECT_USER withObject:user];
//        
//        // may not be needed, since "objects" is a reference. Check and go back later...
//        //[self.radioObjects replaceObjectAtIndex:radioIndex withObject:objects];
//        
//        // and update infos and images
//        NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:user.picture];
//        WebImageView* view = [objects objectAtIndex:OBJECT_IMAGE];
//        [view setUrl:imageURL];
//
//        UILabel* label = [objects objectAtIndex:OBJECT_NAME];
//        label.text = user.name;
//
//        userIndex++;
//    }
    
    NSInteger itemIndex = 0;
    CGFloat xOffset = 0;

    for (User* user in users)
    {
        NSLog(@"update User %p : %@", user, user.name);
        
        // there's only one item on this row. we need another one
        if (self.objects.count <= itemIndex)
        {
            [self addItemGui:user itemIndex:itemIndex xOffset:xOffset];
            itemIndex++;
            xOffset += (self.frame.size.width / 2.f);
            continue;
        }

        NSMutableArray* objects = [self.objects objectAtIndex:itemIndex];

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
        NSLog(@"%@  %@",label.text, user.name);


        itemIndex++;
        xOffset += (self.frame.size.width / 2.f);

    }

    // we had two radios in this row, but we only need one for this update
    if (self.objects.count > users.count)
    {
        NSMutableArray* objects = [self.objects objectAtIndex:1];

        UIView* container = [objects objectAtIndex:OBJECT_CONTAINER];
        [container removeFromSuperview];
        [container release];
        
        //        Radio* radio = [objects objectAtIndex:RADIO_OBJECT_RADIO];
        //        [radio release];
        
        [self.objects removeObjectAtIndex:1];
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


@end
