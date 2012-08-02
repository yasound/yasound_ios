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

static NSString* ProfilCellRadioIdentifier = @"ProfilCellRadio";


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier items:(NSArray*)items target:(id)target action:(SEL)action;
{
    if (self = [super initWithFrame:frame reuseIdentifier:cellIdentifier]) 
    {
        self.frame = frame;
        self.target = target;
        self.action = action;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _panGestureRunning = NO;
        _containerLastTranslation = 0;
        
        [self updateWithItems:items];
        
        _pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:_pgr];
        _pgr.delegate = self;
        [_pgr release];

//        UITapGestureRecognizer* tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//        [self addGestureRecognizer:tgr];
//        //tgr.delegate = self;
//        [tgr release];

//        _slgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
//        [_slgr setDirection:UISwipeGestureRecognizerDirectionLeft];
//        _slgr.delegate = self;
//        [self addGestureRecognizer:_slgr];
//        [_slgr release];
//
//        _srgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
//        [_srgr setDirection:UISwipeGestureRecognizerDirectionRight];
//        _srgr.delegate = self;
//        [self addGestureRecognizer:_srgr];
//        [_srgr release];
        
        


  }
  return self;
}



- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer
{
    if ((gestureRecognizer == _slgr) || (gestureRecognizer == _srgr))
    {
        return !_panGestureRunning;
    }
    
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


- (void)handleTap:(UITapGestureRecognizer*)tgr
{
    self.translationX = 0;
    
    if ([self.timer isValid])
        [self.timer invalidate];
}

#define SWIPE_TRANSLATION_FACTOR 2.f
#define SWIPE_TRANSLATION_DECELERATION 6.f

//- (void)handleSwipeLeft:(UISwipeGestureRecognizer*)sgr
//{
//    NSLog(@"swipe %d", sgr.direction );
//    
//    if ([self.timer isValid])
//        [self.timer invalidate];
//    
//    self.translationX = SWIPE_TRANSLATION;
//    
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(onSwipeAnimateLeft:) userInfo:nil repeats:YES];
//}
//
//
//- (void)handleSwipeRight:(UISwipeGestureRecognizer*)sgr
//{
//    NSLog(@"swipe %d", sgr.direction );
//    
//    if ([self.timer isValid])
//        [self.timer invalidate];
//    
//    self.translationX = SWIPE_TRANSLATION;
//    
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(onSwipeAnimateRight:) userInfo:nil repeats:YES];
//}

- (void)onSwipeAnimateLeft:(NSTimer*)timer
{
    if ((self.translationX <= 0) ||  (self.container == nil))
    {
        self.translationX = 0;
        [self.timer invalidate];
        return;
    }

    [self translateByContainer:-self.translationX];
        
//    self.containerPosX = self.containerPosX - self.translationX;
//    self.container.frame = CGRectMake(self.containerPosX, self.container.frame.origin.y, self.container.frame.size.width, self.container.frame.size.height);
//    self.translationX = self.translationX - (self.translationX/SWIPE_TRANSLATION_DECELERATION);
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
//    self.containerPosX = self.containerPosX + self.translationX;
//    self.container.frame = CGRectMake(self.containerPosX, self.container.frame.origin.y, self.container.frame.size.width, self.container.frame.size.height);
//    self.translationX = self.translationX - (self.translationX/SWIPE_TRANSLATION_DECELERATION);
}




#define PAN_DELTA_THRESHOLD_FOR_ANIMATE 10.f

-(void)handlePan:(UIPanGestureRecognizer *)pgr
{
    if (pgr.state == UIGestureRecognizerStateBegan)
    {
        _panGestureRunning = YES;
        
        if ([self.timer isValid])
            [self.timer invalidate];
        
        _containerStartPosX = self.container.frame.origin.x;
//        NSLog(@"self.container.frame %.2f %.2f   %.2f x %.2f", self.container.frame.origin.x, self.container.frame.origin.y, self.container.frame.size.width, self.container.frame.size.height);
    }
    else
        if (pgr.state == UIGestureRecognizerStateChanged)
        {
            CGPoint translation = [pgr translationInView:pgr.view];
            
            //NSLog(@"translation %.2f %.2f", translation.x, translation.y);
            
            //        CGRect newFrame = frontView.frame;
            //        newFrame.origin.y = newFrame.origin.y + translation.y;
            //        frontView.frame = newFrame;
            
            //        [pgr setTranslation:CGPointZero inView:pgr.view];
            
            if (self.container)
            {
                [self translateToContainer:_containerStartPosX + translation.x];
//                CGFloat posX = self.containerPosX + translation.x;
//                self.container.frame = CGRectMake(posX, self.container.frame.origin.y, self.container.frame.size.width, self.container.frame.size.height);
            }
            
            
            _containerDeltaTranslation = translation.x - _containerLastTranslation;
            _containerLastTranslation = translation.x;
        }
    
        else if (pgr.state == UIGestureRecognizerStateEnded)
        {
//            CGPoint translation = [pgr translationInView:pgr.view];
//            
//            CGFloat delta = translation.x - _containerLastTranslation;

            
            NSLog(@"END TRANSLATION DELTA %.2f", _containerDeltaTranslation);

            _panGestureRunning = NO;
            
            if (fabs(_containerDeltaTranslation) >= PAN_DELTA_THRESHOLD_FOR_ANIMATE)
            {
                NSLog(@"ANIMATE");
                //[self translateByContainer:_containerDeltaTranslation];
                
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
    
//    NSLog(@"posX %.2f   posXMin %.2f", posX, _containerPosXMin);
    
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
    
    if (items != nil)
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
        title.text = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@ %@ %@", radio.name, radio.name, radio.name, radio.name, radio.name, radio.name, radio.name, radio.name, radio.name, radio.name];
        [itemContainer addSubview:title];

        // interactive view : catch the "press down" and "press up" actions
        [self.userObjects addObject:radioMask];
        
//        InteractiveView* interactiveView = [[InteractiveView alloc] initWithFrame:sheetContainer.frame target:self action:@selector(onInteractivePressedUp:) withObject:[NSNumber numberWithInteger:itemIndex]];
//        [interactiveView setTargetOnTouchDown:self action:@selector(onInteractivePressedDown:) withObject:[NSNumber numberWithInteger:itemIndex]];
//        [itemContainer addSubview:interactiveView];


        itemIndex++;
        xOffset += (sheetContainer.frame.size.width);
    }

    self.container.frame = CGRectMake(0, 0, xOffset, self.frame.size.height);
    
    _containerPosXMin = - xOffset + self.frame.size.width;
    _containerPosXMax = 0;

    
    //LBDEBUG
//    NSLog(@"contentsSize %.2f, %.2f", self.scrollview.contentSize.width, self.scrollview.contentSize.height);
//    NSLog(@"ok");

}


- (void)onInteractivePressedDown:(NSNumber*)nbIndex
{
    // set the "highlighted" image for the radio mask
    NSInteger radioIndex = [nbIndex integerValue];
    UIImageView* radioMask = [self.userObjects objectAtIndex:radioIndex];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Profil.Radio.maskHighlighted" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    [radioMask setImage:[sheet image]];
}


- (void)onInteractivePressedUp:(NSNumber*)nbIndex
{
    // set the "highlighted" image for the radio mask
    NSInteger radioIndex = [nbIndex integerValue];
    UIImageView* radioMask = [self.userObjects objectAtIndex:radioIndex];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Profil.Radio.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    [radioMask setImage:[sheet image]];
    
    Radio* radio = [self.items objectAtIndex:radioIndex];
    
    // and call external action to delegate the radio selection
    [self.target performSelector:self.action withObject:radio];
}




- (void)updateUsers
{
    
}






- (void)dealloc
{
//    [self.cellLoader release];
  [super dealloc];
}



//- (void)onInteractivePressedDown:(NSNumber*)indexNb
//{
//    // set the "highlighted" image for the radio mask
//    NSInteger radioIndex = [indexNb integerValue];
//    NSArray* objects = [self.radioObjects objectAtIndex:radioIndex];
//    UIImageView* radioMask = [objects objectAtIndex:RADIO_OBJECT_MASK];
//    
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Radios.maskHighlighted" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    [radioMask setImage:[sheet image]];
//}
//
//- (void)onInteractivePressedUp:(NSNumber*)indexNb
//{
//    // set back the "normal" image for the radio mask
//    NSInteger radioIndex = [indexNb integerValue];
//    NSArray* objects = [self.radioObjects objectAtIndex:radioIndex];
//    UIImageView* radioMask = [objects objectAtIndex:RADIO_OBJECT_MASK];
//    
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Radios.mask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    [radioMask setImage:[sheet image]];
//    
//    Radio* radio = [objects objectAtIndex:RADIO_OBJECT_RADIO];
//
//    // and call external action to delegate the radio selection
//    [self.target performSelector:self.action withObject:radio];
//}
//




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
//    self.cellBackground.image = _bkgSelected;
//    self.radioAvatarMask.image = _maskSelected;
//
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionTitle" error:nil];
//    [sheet applyToLabel:self.radioTitle class:@"selected"];
//
//    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionSubtitle1" error:nil];
//    [sheet applyToLabel:self.radioSubtitle1 class:@"selected"];
//
//    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionSubtitle2" error:nil];
//    [sheet applyToLabel:self.radioSubtitle2 class:@"selected"];
//
//    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionLikes" error:nil];
//    [sheet applyToLabel:self.radioLikes class:@"selected"];
//
//    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionListeners" error:nil];
//    [sheet applyToLabel:self.radioListeners class:@"selected"];
//  }
//  else
//  {
//    self.cellBackground.image = _bkgBackup;
//    self.radioAvatarMask.image = _maskBackup;
//
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionTitle" error:nil];
//    [sheet applyToLabel:self.radioTitle class:nil];
//    
//    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionSubtitle1" error:nil];
//    [sheet applyToLabel:self.radioSubtitle1 class:nil];
//    
//    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionSubtitle2" error:nil];
//    [sheet applyToLabel:self.radioSubtitle2 class:nil];
//    
//    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionLikes" error:nil];
//    [sheet applyToLabel:self.radioLikes class:nil];
//    
//    sheet = [[Theme theme] stylesheetForKey:@"Radios.RadioSelectionListeners" error:nil];
//    [sheet applyToLabel:self.radioListeners class:nil];
//  }
//}








//
//
//#pragma mark - TableView Source and Delegate
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    if (self.items == nil)
//        return 0;
//    return [self.items count];
//}
//
//
//
////- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
////{
////    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
////    view.frame = CGRectMake(0, 0, 100, 100);
////    cell.backgroundView = view;
////    [view release];
////}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
//{
//    return 100;
//}





//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
//    if (cell == nil)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
//    }
//    
//    cell.textLabel.text = @"prout";
//    cell.textLabel.frame = CGRectMake(0, 0, 100, 100);
//    
//    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,100)];
//    view.backgroundColor = [UIColor redColor];
//    cell.backgroundView = view;
//    cell.selectedBackgroundView = view;
//    
//    
//    return cell;
//    
//    
//    
//    
//    if (self.displayRadios)
//    {
//        Radio* radio = [self.items objectAtIndex:indexPath.row];
//        
//        ProfilCellRadio* cell = [tableView dequeueReusableCellWithIdentifier:ProfilCellRadioIdentifier];
//        if (cell == nil)
//        {
//            NSArray* topLevelItems = [self.cellLoader instantiateWithOwner:self options:nil];
//            cell = [topLevelItems objectAtIndex:0];
//        }
//        
//        [cell updateWithRadio:radio];
//        
//        return cell;
//    }
//    
//    return nil;
//}
//
//
//
//- (NSIndexPath *)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    return nil;
//}






#pragma mark - UIScrollViewDelegate


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    if (!_waitingForPreviousEvents)
//    {
//        float offset = scrollView.contentOffset.y;
//        float contentHeight = scrollView.contentSize.height;
//        float viewHeight = scrollView.bounds.size.height;
//        
//        if ((offset > 0) && (offset + viewHeight > contentHeight + WALL_WAITING_ROW_HEIGHT))
//        {
//            [self askForPreviousEvents];
//        }
//    }
}










@end
