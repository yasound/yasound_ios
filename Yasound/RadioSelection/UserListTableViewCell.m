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
//#define OBJECT_INTERACTIVE_VIEW 4
//#define OBJECT_CONTAINER 5
#define OBJECT_CONTAINER 4



@implementation UserListTableViewCell

@synthesize objects;
@synthesize target;
@synthesize action;

#define USER_IMAGE_SIZE 65.f

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
            xOffset += (self.frame.size.width / 3.f);
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
    BundleStylesheet* sheetContainer = [[Theme theme] stylesheetForKey:@"Users.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    CGRect frame = CGRectMake(xOffset, 0, sheetContainer.frame.size.width, sheetContainer.frame.size.height + 32);
    UIView* container = [[UIView alloc] initWithFrame:frame];

    [self addSubview:container];

    // user image
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Users.image" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:user.picture];
    WebImageView* userImage = [[WebImageView alloc] initWithImageAtURL:imageURL];
    userImage.frame = CGRectMake(sheet.frame.origin.x, sheet.frame.origin.y, sheet.frame.size.width, sheet.frame.size.height);
    [container addSubview:userImage];

    // draw circle mask
    userImage.layer.masksToBounds = YES;
    userImage.layer.cornerRadius = USER_IMAGE_SIZE / 2.f;

    // user mask
    sheet = [[Theme theme] stylesheetForKey:@"Users.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    UIImageView* userMask = [sheet makeImage];
    UIButton* userButton = [sheet makeButton];
    [userButton addTarget:self action:@selector(onInteractivePressedUp:) forControlEvents:UIControlEventTouchUpInside];
    userButton.tag = itemIndex;
    [container addSubview:userButton];

    // name
    sheet = [[Theme theme] stylesheetForKey:@"Users.name"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* name = [sheet makeLabel];
    name.adjustsFontSizeToFitWidth = YES;
    name.text = user.name;
    [container addSubview:name];

    //            InteractiveView* interactiveView = nil;
    sheet = [[Theme theme] stylesheetForKey:@"Users.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];

    // interactive view : catch the "press down" and "press up" actions
//    InteractiveView* interactiveView0 = [[InteractiveView alloc] initWithFrame:sheet.frame target:self action:@selector(onInteractivePressedUp:) withObject:[NSNumber numberWithInteger:itemIndex]];

//    [interactiveView0 setTargetOnTouchDown:self action:@selector(onInteractivePressedDown:) withObject:[NSNumber numberWithInteger:itemIndex]];
//    [container addSubview:interactiveView0];

    // store objects
    NSMutableArray* objects = [NSMutableArray arrayWithObjects:user, userImage, userButton, name,container, nil];

    assert(objects.count == 5);

    [self.objects addObject:objects];
            
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
    if ((self.objects == nil) || (self.objects.count == 0))
        return;
    
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
            xOffset += (self.frame.size.width / 3.f);
            continue;
        }

        NSMutableArray* objects = [self.objects objectAtIndex:itemIndex];

        // replace radio
        [objects replaceObjectAtIndex:OBJECT_USER withObject:user];

        // may not be needed, since "objects" is a reference. Check and go back later...
        //[self.radioObjects replaceObjectAtIndex:radioIndex withObject:objects];

        // and update infos and images
        NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:user.picture];
        
        
        
//        BundleStylesheet* sheet = [sheet ]
//        [view setImage:[UIImage image]]
        
        WebImageView* view = [objects objectAtIndex:OBJECT_IMAGE];
        [view setUrl:imageURL];

        UILabel* label = [objects objectAtIndex:OBJECT_NAME];
        label.text = user.name;
        NSLog(@"%@  %@",label.text, user.name);


        itemIndex++;
        xOffset += (self.frame.size.width / 3.f);

    }

    // we had two radios in this row, but we only need one for this update
    if (self.objects.count > users.count)
    {
        NSMutableArray* objects = [self.objects objectAtIndex:1];

        UIView* container = [objects objectAtIndex:OBJECT_CONTAINER];
        [container removeFromSuperview];
        [container release];
        
        [self.objects removeObjectAtIndex:1];
    }
    
}






- (void)dealloc
{
  [super dealloc];
}



//- (void)onInteractivePressedDown:(NSNumber*)indexNb
//{
//    // set the "highlighted" image for the user mask
//    NSInteger userIndex = [indexNb integerValue];
//    NSArray* objects = [self.objects objectAtIndex:userIndex];
//    UIImageView* userMask = [objects objectAtIndex:OBJECT_MASK];
//    
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Users.maskHighlighted" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    [userMask setImage:[sheet image]];
//}

//- (void)onInteractivePressedUp:(NSNumber*)indexNb
- (void)onInteractivePressedUp:(id)sender
{
    UIButton* button = sender;
    NSInteger userIndex = button.tag;
    
    // set back the "normal" image for the user mask
    NSArray* objects = [self.objects objectAtIndex:userIndex];
//    UIImageView* userMask = [objects objectAtIndex:OBJECT_MASK];
    
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Users.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    [userMask setImage:[sheet image]];
    
    User* user = [objects objectAtIndex:OBJECT_USER];

    // and call external action to delegate the radio selection
    [self.target performSelector:self.action withObject:user];
}


@end
