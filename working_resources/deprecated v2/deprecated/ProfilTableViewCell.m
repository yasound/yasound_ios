//
//  ProfilTableViewCell.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "ProfilTableViewCell.h"
#import "Theme.h"
#import "YasoundDataCache.h"
#import "TimeProfile.h"

#import "InteractiveView.h"





@implementation ProfilTableViewCell

@synthesize container;
@synthesize items;
@synthesize target;
@synthesize action;
@synthesize displayRadios;
@synthesize displayUsers;
@synthesize timer;
@synthesize translationX;



- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier items:(NSArray*)items target:(id)target action:(SEL)action;
{
    if (self = [super initWithFrame:frame reuseIdentifier:cellIdentifier]) 
    {
        self.frame = frame;
        self.target = target;
        self.action = action;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _containerLastTranslation = 0;
        
        [self updateWithItems:items];
        
        _pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:_pgr];
        _pgr.delegate = self;
        [_pgr release];

  }
  return self;
}



- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer
{
    [self cancelPress];
        
    if (gestureRecognizer == _pgr)
    {
        UIView *cell = [_pgr view];
        CGPoint translation = [_pgr translationInView:[cell superview]];
        
        // Check for horizontal gesture
        if (fabsf(translation.x) > fabsf(translation.y))
        {
            return YES;
        }
        
        return NO;
    }
    
    return YES;
}




#define SWIPE_TRANSLATION_FACTOR 2.f
#define SWIPE_TRANSLATION_DECELERATION 6.f


- (void)onSwipeAnimateLeft:(NSTimer*)timer
{
    if ((self.translationX <= 0) ||  (self.container == nil))
    {
        self.translationX = 0;
        [self.timer invalidate];
        return;
    }

    [self translateByContainer:-self.translationX];
}

- (void)onSwipeAnimateRight:(NSTimer*)timer
{
    if ((self.translationX <= 0) ||  (self.container == nil))
    {
        self.translationX = 0;
        [self.timer invalidate];
        return;
    }
    
    [self translateByContainer:self.translationX];
}




#define PAN_DELTA_THRESHOLD_FOR_ANIMATE 10.f

-(void)handlePan:(UIPanGestureRecognizer *)pgr
{
    if (pgr.state == UIGestureRecognizerStateBegan)
    {
        if ([self.timer isValid])
            [self.timer invalidate];
        
        _containerStartPosX = self.container.frame.origin.x;
    }
    else
        if (pgr.state == UIGestureRecognizerStateChanged)
        {
            CGPoint translation = [pgr translationInView:pgr.view];
            
            if (self.container)
            {
                [self translateToContainer:_containerStartPosX + translation.x];
            }
            
            _containerDeltaTranslation = translation.x - _containerLastTranslation;
            _containerLastTranslation = translation.x;
        }
    
        else if (pgr.state == UIGestureRecognizerStateEnded)
        {
            if (fabs(_containerDeltaTranslation) >= PAN_DELTA_THRESHOLD_FOR_ANIMATE)
            {
                self.translationX = fabs(_containerDeltaTranslation) * SWIPE_TRANSLATION_FACTOR;
                
                if (_containerDeltaTranslation < 0)
                {
                self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(onSwipeAnimateLeft:) userInfo:nil repeats:YES];
                }
                else
                {
                
                self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(onSwipeAnimateRight:) userInfo:nil repeats:YES];
                }
            }
        }
}




- (void)translateToContainer:(CGFloat)posX
{
    self.containerPosX = posX;
    
    // crop position
    if (self.containerPosX > _containerPosXMax)
    {
        self.containerPosX = _containerPosXMax;
    }
    else if (self.containerPosX < _containerPosXMin)
    {
        self.containerPosX = _containerPosXMin;
    }
    self.container.frame = CGRectMake(self.containerPosX, self.container.frame.origin.y, self.container.frame.size.width, self.container.frame.size.height);
}


- (void)translateByContainer:(CGFloat)translationX
{
    BOOL stopAnim = NO;
    
    self.containerPosX = self.containerPosX + translationX;
    if (self.containerPosX > _containerPosXMax)
    {
        // crop position
        self.containerPosX = _containerPosXMax;
        stopAnim = YES;
    }
    else if (self.containerPosX < _containerPosXMin)
    {
        // crop position
        self.containerPosX = _containerPosXMin;
        stopAnim = YES;
    }
        
    self.container.frame = CGRectMake(self.containerPosX, self.container.frame.origin.y, self.container.frame.size.width, self.container.frame.size.height);
    
    if (stopAnim)
    {
        self.translationX = 0;
        if ([self.timer isValid])
            [self.timer invalidate];
    }
    else
    {
        // iterate
        self.translationX = self.translationX - (self.translationX/SWIPE_TRANSLATION_DECELERATION);
    }
}








- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if(!newSuperview)
    {
        //LBDEBUG TODO
//        for (NSArray* objects in self.radioObjects)
//        {
//            WebImageView* view = [objects objectAtIndex:RADIO_OBJECT_IMAGE];
//            if (view)
//                [view releaseCache];
//            view = [objects objectAtIndex:RADIO_OBJECT_USER_IMAGE];
//            if (view)
//                [view releaseCache];
//        }
    }
}




- (void)updateWithItems:(NSArray*)items;
{
    self.items = items;
    
    if ((items != nil) && (items.count > 0))
    {
        id object = [items objectAtIndex:0];
        if ([object isKindOfClass:[Radio class]])
        {
            self.displayRadios = YES;
            self.displayUsers = NO;
        }
        
        else if ([object isKindOfClass:[User class]])
        {
            self.displayRadios = NO;
            self.displayUsers = YES;
        }
    }
    
    if (self.container != nil)
    {
        [self.container removeFromSuperview];
        self.container = nil;
    }
    
    
    self.container = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.container];
    self.containerPosX = 0;
    
    if (self.displayRadios)
        [self updateRadios];
    else
        [self updateUsers];

    
}

- (void)updateRadios
{
    NSInteger itemIndex = 0;
    CGFloat xOffset = 0;
    BundleStylesheet* sheet = nil;
    
    if (self.userObjects)
        [self.userObjects release];
    self.userObjects = [[NSMutableArray alloc] init];
    
    for (Radio* radio in self.items)
    {
        BundleStylesheet* sheetContainer = [[Theme theme] stylesheetForKey:@"Profil.Radio.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        sheetContainer.frame = CGRectMake(sheetContainer.frame.origin.x + xOffset, sheetContainer.frame.origin.y, sheetContainer.frame.size.width, sheetContainer.frame.size.height);
        UIView* itemContainer = [[UIView alloc] initWithFrame:sheetContainer.frame];
        [self.container addSubview:itemContainer];

        // radio image
        sheet = [[Theme theme] stylesheetForKey:@"Profil.Radio.image" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:radio.picture];
        WebImageView* radioImage = [[WebImageView alloc] initWithImageAtURL:imageURL];
        radioImage.frame = sheet.frame;
        [itemContainer addSubview:radioImage];

        // radio mask
        sheet = [[Theme theme] stylesheetForKey:@"Profil.Radio.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        sheet.frame = CGRectMake(0, 0, sheet.frame.size.width, sheet.frame.size.height);
        UIImageView* radioMask = [sheet makeImage];
        [itemContainer addSubview:radioMask];

        // title
        sheet = [[Theme theme] stylesheetForKey:@"Profil.Radio.title"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UILabel* title = [sheet makeLabel];
        title.text = radio.name;
        [itemContainer addSubview:title];

        // interactive view : catch the "press down" and "press up" actions
        [self.userObjects addObject:radioMask];
        
        InteractiveView* interactiveView = [[InteractiveView alloc] initWithFrame:sheetContainer.frame target:self action:@selector(onInteractivePressedUp:) withObject:[NSNumber numberWithInteger:itemIndex]];
        [interactiveView setTargetOnTouchDown:self action:@selector(onInteractivePressedDown:) withObject:[NSNumber numberWithInteger:itemIndex]];
        [itemContainer addSubview:interactiveView];


        itemIndex++;
        xOffset += (sheetContainer.frame.size.width);
    }

    self.container.frame = CGRectMake(0, 0, xOffset, self.frame.size.height);
    
    if (xOffset > self.frame.size.width)
        _containerPosXMin = - xOffset + self.frame.size.width;
    else
        _containerPosXMin = 0;
        
    _containerPosXMax = 0;

}




- (void)updateUsers
{
    NSInteger itemIndex = 0;
    CGFloat xOffset = 0;
    BundleStylesheet* sheet = nil;
    
    if (self.userObjects)
        [self.userObjects release];
    self.userObjects = [[NSMutableArray alloc] init];
    
    for (User* user in self.items)
    {
        BundleStylesheet* sheetContainer = [[Theme theme] stylesheetForKey:@"Profil.User.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        CGRect containerFrame = CGRectMake(sheetContainer.frame.origin.x + xOffset, sheetContainer.frame.origin.y, sheetContainer.frame.size.width, sheetContainer.frame.size.height);
        UIView* itemContainer = [[UIView alloc] initWithFrame:containerFrame];
        [self.container addSubview:itemContainer];
        
        // user image
        sheet = [[Theme theme] stylesheetForKey:@"Profil.User.image" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:user.picture];
        WebImageView* image = [[WebImageView alloc] initWithImageAtURL:imageURL];
        image.frame = sheet.frame;
        [itemContainer addSubview:image];
        
        // radio mask
        sheet = [[Theme theme] stylesheetForKey:@"Profil.User.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        CGRect frame = CGRectMake(0, 0, sheet.frame.size.width, sheet.frame.size.height);
        UIImageView* mask = [sheet makeImage];
        mask.frame = frame;
        [itemContainer addSubview:mask];
        
        // title
        sheet = [[Theme theme] stylesheetForKey:@"Profil.User.title"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UILabel* title = [sheet makeLabel];
        title.text = user.name;
        [itemContainer addSubview:title];
        
        // interactive view : catch the "press down" and "press up" actions
        [self.userObjects addObject:mask];
        
        InteractiveView* interactiveView = [[InteractiveView alloc] initWithFrame:CGRectMake(0, 0, containerFrame.size.width, containerFrame.size.height) target:self action:@selector(onInteractivePressedUp:) withObject:[NSNumber numberWithInteger:itemIndex]];
        [interactiveView setTargetOnTouchDown:self action:@selector(onInteractivePressedDown:) withObject:[NSNumber numberWithInteger:itemIndex]];
        [itemContainer addSubview:interactiveView];
        
        
        itemIndex++;
        
        NSLog(@"xOffset %.2f    width %.2f    x %.2f",  xOffset, sheetContainer.frame.size.width, sheetContainer.frame.origin.x);
        
        xOffset += (sheetContainer.frame.size.width + sheetContainer.frame.origin.x);
        
        
        
    }
    
    self.container.frame = CGRectMake(0, 0, xOffset, self.frame.size.height);
    
    if (xOffset > self.frame.size.width)
        _containerPosXMin = - xOffset + self.frame.size.width;
    else
        _containerPosXMin = 0;
    
    _containerPosXMax = 0;
}




- (void)onInteractivePressedDown:(NSNumber*)nbIndex
{
    if (self.userObjects.count == 0)
        return;
    
    assert(self.userObjects.count > 0);

    // set the "highlighted" image for the radio mask
    NSInteger radioIndex = [nbIndex integerValue];
    UIImageView* radioMask = [self.userObjects objectAtIndex:radioIndex];
    
    _selectedIndex = radioIndex;
    
    BundleStylesheet* sheet = nil;
    if (self.displayRadios)
        sheet = [[Theme theme] stylesheetForKey:@"Profil.Radio.maskHighlighted" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    else
        sheet = [[Theme theme] stylesheetForKey:@"Profil.User.maskHighlighted" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    [radioMask setImage:[sheet image]];
}


- (void)onInteractivePressedUp:(NSNumber*)nbIndex
{
    if (self.userObjects.count == 0)
        return;
    
    // it's been canceled
    if (_selectedIndex < 0)
        return;
    
    _selectedIndex = -1;
    
    assert(self.userObjects.count > 0);

    // set the "highlighted" image for the radio mask
    NSInteger radioIndex = [nbIndex integerValue];
    UIImageView* radioMask = [self.userObjects objectAtIndex:radioIndex];
    
    BundleStylesheet* sheet = nil;
    if (self.displayRadios)
        sheet = [[Theme theme] stylesheetForKey:@"Profil.Radio.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    else
        sheet = [[Theme theme] stylesheetForKey:@"Profil.User.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];

    [radioMask setImage:[sheet image]];
    
    
    assert(self.items.count > 0);

    Radio* radio = [self.items objectAtIndex:radioIndex];
    
    // and call external action to delegate the radio selection
   [self.target performSelector:self.action withObject:radio];
}


- (void)cancelPress
{
    if (_selectedIndex < 0)
        return;
    if (self.userObjects.count == 0)
        return;

    UIImageView* radioMask = [self.userObjects objectAtIndex:_selectedIndex];
    
    BundleStylesheet* sheet = nil;
    if (self.displayRadios)
        sheet = [[Theme theme] stylesheetForKey:@"Profil.Radio.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    else
        sheet = [[Theme theme] stylesheetForKey:@"Profil.User.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    
    [radioMask setImage:[sheet image]];
}








- (void)dealloc
{
//    [self.cellLoader release];
  [super dealloc];
}










@end
