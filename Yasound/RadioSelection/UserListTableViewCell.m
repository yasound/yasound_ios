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
        NSInteger userIndex = 0;
        
        for (User* user in users)
        {
            
//            BundleStylesheet* sheetContainer = [[Theme theme] stylesheetForKey:@"Users.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//            sheetContainer.frame = CGRectMake(sheetContainer.frame.origin.x + xOffset, sheetContainer.frame.origin.y, sheetContainer.frame.size.width, sheetContainer.frame.size.height);
            BundleStylesheet* sheetContainer = [[Theme theme] stylesheetForKey:@"Users.container" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            UIView* container = [[UIView alloc] initWithFrame:sheetContainer.frame];
            [self addSubview:container];
            
            // user image
            sheet = [[Theme theme] stylesheetForKey:@"Users.image" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:user.picture];
            WebImageView* userImage = [[WebImageView alloc] initWithImageAtURL:imageURL];
            userImage.frame = CGRectMake(sheet.frame.origin.x + xOffset, sheet.frame.origin.y, sheet.frame.size.width, sheet.frame.size.height);
            [container addSubview:userImage];

            // draw circle mask
            userImage.layer.masksToBounds = YES;
            userImage.layer.cornerRadius = USER_IMAGE_SIZE / 2.f;

            // user mask
            sheet = [[Theme theme] stylesheetForKey:@"Users.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            UIImageView* userMask = [sheet makeImage];
            CGRect maskRect = CGRectMake(sheet.frame.origin.x + xOffset, sheet.frame.origin.y, sheet.frame.size.width, sheet.frame.size.height);
            userMask.frame = maskRect;
            [container addSubview:userMask];
            
            
            // name
            sheet = [[Theme theme] stylesheetForKey:@"Users.name"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
            UILabel* name = [sheet makeLabel];
            name.frame = CGRectMake(name.frame.origin.x + xOffset, name.frame.origin.y, name.frame.size.width, name.frame.size.height);
            name.text = user.name;
            [container addSubview:name];
            
            InteractiveView* interactiveView = nil;
            
            // store objects
            NSMutableArray* objects = [NSMutableArray arrayWithObjects:user, userImage, userMask, name, interactiveView, nil];
            
            
            [self.objects addObject:objects];
            
            xOffset += (self.frame.size.width / 2.f);
            
        }

       sheet = [[Theme theme] stylesheetForKey:@"Users.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];

            // interactive view : catch the "press down" and "press up" actions
            InteractiveView* interactiveView0 = [[InteractiveView alloc] initWithFrame:CGRectMake(sheet.frame.origin.x,sheet.frame.origin.y,sheet.frame.size.width,sheet.frame.size.height) target:self action:@selector(onInteractivePressedUp:) withObject:[NSNumber numberWithInteger:0]];
            [interactiveView0 setTargetOnTouchDown:self action:@selector(onInteractivePressedDown:) withObject:[NSNumber numberWithInteger:0]];
            [self addSubview:interactiveView0];

        InteractiveView* interactiveView1 = [[InteractiveView alloc] initWithFrame:CGRectMake(sheet.frame.origin.x + 160,sheet.frame.origin.y,sheet.frame.size.width,sheet.frame.size.height) target:self action:@selector(onInteractivePressedUp:) withObject:[NSNumber numberWithInteger:1]];
        [interactiveView1 setTargetOnTouchDown:self action:@selector(onInteractivePressedDown:) withObject:[NSNumber numberWithInteger:1]];
        [self addSubview:interactiveView1];
        
            
//            userIndex++;
        
//        if (delay)
//        {
//            self.alpha = 0;
//            [UIView beginAnimations:nil context:NULL];
//            [UIView setAnimationDuration:delay];
//            self.alpha = 1;
//            [UIView commitAnimations];
//            
//            delay += 0.15;
//        }
        
        
//        UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        button.frame  = CGRectMake(0, 0, 100, 100);
//        [self addSubview:button];
//
//        UIButton* button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        button2.frame  = CGRectMake(200, 0, 100, 100);
//        [self addSubview:button2];


            
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


@end