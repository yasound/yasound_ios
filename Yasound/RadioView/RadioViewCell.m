//
//  RadioViewCell.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioViewCell.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "WallEvent.h"
#import "YasoundDataProvider.h"

#import <QuartzCore/QuartzCore.h>

@implementation RadioViewCell

@synthesize cellView;
@synthesize cellViewX;
@synthesize avatar;
@synthesize avatarMask;
@synthesize date;
@synthesize user;
@synthesize message;
@synthesize messageBackground;
@synthesize separator;
@synthesize cellEditView;

- (NSString*) dateToString:(NSDate*)d
{
  NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:@"dd/MM' 'HH:mm"];
  NSString* s = [dateFormat stringFromDate:d];
  [dateFormat release];
  return s;
}



#define MESSAGE_SPACING 4

#define INTERACTIVE_ZONE_SIZE 64

#define ANIMATION_DURATION 0.1


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier ownRadio:(BOOL)ownRadio event:(WallEvent*)ev indexPath:(NSIndexPath*)indexPath target:(id)target action:(SEL)action
{
    self = [super initWithFrame:frame reuseIdentifier:CellIdentifier];
    if (self) 
    {
        _editMode = NO;
        _ownRadio = ownRadio;
        _interactiveZoneSize = (_ownRadio)? 3 * INTERACTIVE_ZONE_SIZE : 1 * INTERACTIVE_ZONE_SIZE;

        
        _myTarget = target;
        _myAction = action;
        
        BundleStylesheet* sheet = nil;
        
        sheet = [[Theme theme] stylesheetForKey:@"CellMessage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIFont* messageFont = [sheet makeFont];
        CGFloat messageWidth = sheet.frame.size.width;

        
        assert([ev isTextHeightComputed] == YES);
        CGFloat height = [ev getTextHeight];
        
        
        sheet = [[Theme theme] stylesheetForKey:@"MessageCellBackground" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        CGRect cellFrame = self.bounds;

        UIView* cellView = [[UIView alloc] initWithFrame:cellFrame];
        cellView.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
        self.cellView = cellView;
        self.cellView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.cellView];
        [cellView release];
        
        // avatar
        sheet = [[Theme theme] stylesheetForKey:@"CellAvatar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.avatar = [[WebImageView alloc] initWithImageAtURL:[[YasoundDataProvider main] urlForPicture:ev.user_picture]];
        self.avatar.frame = sheet.frame;
        [self.cellView addSubview:self.avatar];
        
        // set target from parent
        self.avatarMask = [[InteractiveView alloc] initWithFrame:sheet.frame target:self action:@selector(onAvatarClicked:)];
        [self.cellView addSubview:self.avatarMask];
        
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = 6;

        // date
        sheet = [[Theme theme] stylesheetForKey:@"CellDate" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.date = [sheet makeLabel];
        self.date.text = [self dateToString:ev.start_date];
        [self.cellView addSubview:self.date];
        
        // user
        sheet = [[Theme theme] stylesheetForKey:@"CellUser" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.user = [sheet makeLabel];
        self.user.text = ev.user_name;
        [self.cellView addSubview:self.user];

        // message background
        BundleStylesheet* messageSheet = [[Theme theme] stylesheetForKey:@"CellMessage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.messageBackground = [[UIView alloc] initWithFrame:messageSheet.frame];
        self.messageBackground.frame = CGRectMake(messageSheet.frame.origin.x, messageSheet.frame.origin.y, messageSheet.frame.size.width, height + 2*MESSAGE_SPACING);
        
        self.messageBackground.layer.masksToBounds = YES;
        self.messageBackground.layer.cornerRadius = 4;
        self.messageBackground.layer.borderColor = [UIColor colorWithRed:231.f/255.f green:231.f/255.f blue:231.f/255.f alpha:1].CGColor;
        self.messageBackground.layer.borderWidth = 1.0; 
        self.messageBackground.layer.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1].CGColor;
        [self.cellView addSubview:self.messageBackground];

        
        // message
        self.message = [messageSheet makeLabel];
        self.message.text = ev.text;
        self.message.frame = CGRectMake(self.message.frame.origin.x + MESSAGE_SPACING, self.message.frame.origin.y + MESSAGE_SPACING, self.message.frame.size.width - 2*MESSAGE_SPACING, height);
        
        [self.message setLineBreakMode:UILineBreakModeWordWrap];
        [self.message setNumberOfLines:0];        
        [self.cellView addSubview:self.message];
        
        sheet = [[Theme theme] stylesheetForKey:@"CellSeparator" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.separator = [[UIImageView alloc] initWithImage:[sheet image]];
        self.separator.frame = CGRectMake(0, height + THE_REST_OF_THE_CELL_HEIGHT - sheet.frame.size.height, sheet.frame.size.width, sheet.frame.size.height);
        [self.cellView addSubview:self.separator];
        
        
        
        
        
        
        UISwipeGestureRecognizer* swipeRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight)] autorelease];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipeRight];
        
        UISwipeGestureRecognizer* swipeLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeLeft)] autorelease];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipeLeft];

        UIPanGestureRecognizer* pan = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)] autorelease];
        pan.maximumNumberOfTouches = 2;
        pan.minimumNumberOfTouches = 1;
        [self addGestureRecognizer:pan];

        

    }
    return self;
}



- (void)update:(WallEvent*)ev indexPath:(NSIndexPath*)indexPath
{
    assert([ev isTextHeightComputed] == YES);
    CGFloat height = [ev getTextHeight];
    
    self.date.text = [self dateToString:ev.start_date];
    self.user.text = ev.user_name;
    self.message.text = ev.text;
    
    self.messageBackground.frame = CGRectMake(self.messageBackground.frame.origin.x, self.messageBackground.frame.origin.y, self.messageBackground.frame.size.width, height + 2 * MESSAGE_SPACING);
    
    self.message.frame = CGRectMake(self.message.frame.origin.x, self.message.frame.origin.y, self.message.frame.size.width, height);
    
    self.separator.frame = CGRectMake(0, height + THE_REST_OF_THE_CELL_HEIGHT - 2, self.separator.frame.size.width, self.separator.frame.size.height);
    
  [self.avatar setUrl:[[YasoundDataProvider main] urlForPicture:ev.user_picture]];
    
}


- (void)onAvatarClicked:(id)sender
{
    if (_myTarget == nil)
        return;
    
    [_myTarget performSelector:_myAction withObject:self];
}














-(void)onPan:(UIPanGestureRecognizer *)gesture;
{
    UIView *piece = [gesture view];
    
    if ([gesture state] == UIGestureRecognizerStateBegan)
        self.cellViewX = self.cellView.frame.origin.x;
        
    CGPoint translation = [gesture translationInView:self];

    //NSLog(@"%.2f", translation.x);

    if ([gesture state] == UIGestureRecognizerStateBegan || [gesture state] == UIGestureRecognizerStateChanged) 
    {
        CGFloat newX = cellViewX + translation.x;
        if (newX < -_interactiveZoneSize)
            newX = -_interactiveZoneSize;
        else if (newX > 0)
            newX = 0;
        
        self.cellView.frame = CGRectMake(newX, self.cellView.frame.origin.y, self.cellView.frame.size.width, self.cellView.frame.size.height);
    }

    if ([gesture state] == UIGestureRecognizerStateCancelled)
        [self deactivateEditModeAnimated:YES];
        
    else if ([gesture state] == UIGestureRecognizerStateEnded)
    {

        if (!_editMode)
        {
            if ((translation.x > -(INTERACTIVE_ZONE_SIZE)) && (translation.x < 0))
                [self deactivateEditModeAnimated:YES];
            else if (translation.x < -(INTERACTIVE_ZONE_SIZE))
                    [self activateEditModeAnimated:YES];
        }
        else
        {
            if ((translation.x > 0) && (translation.x < INTERACTIVE_ZONE_SIZE))
                [self activateEditModeAnimated:YES];
            else if (translation.x > INTERACTIVE_ZONE_SIZE)
                [self deactivateEditModeAnimated:YES];
        }
    }

}




- (void)onSwipeLeft
{
    [self activateEditModeAnimated:YES];
    
}

- (void)onSwipeRight
{
    [self deactivateEditModeAnimated:YES];
}



- (void)activateEditModeAnimated:(BOOL)animated
{
//    if (_editMode)
//        return;
    
    _editMode = YES;
    
    CGRect frame;
    
    frame = CGRectMake(self.bounds.size.width - _interactiveZoneSize, 0, _interactiveZoneSize, self.bounds.size.height);

    
    UIView* view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor grayColor];
    [self addSubview:view];
    [self bringSubviewToFront:self.cellView];
    self.cellEditView = view;
    [view release];
    
    CGRect cellFrameDst = CGRectMake(0 - _interactiveZoneSize, self.cellView.frame.origin.y, self.cellView.frame.size.width, self.cellView.frame.size.height);

    
    
    
    // move button and labels with animation
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:ANIMATION_DURATION];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    }
    
    self.cellView.frame = cellFrameDst;

    if (animated)
    {
        [UIView commitAnimations];
    }
}





- (void)deactivateEditModeAnimated:(BOOL)animated
{
//    if (!_editMode)
//        return;
    _editMode = NO;
    

    CGRect cellFrameDst = CGRectMake(0, self.cellView.frame.origin.y, self.cellView.frame.size.width, self.cellView.frame.size.height);
    
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:ANIMATION_DURATION];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    }
    
    self.cellView.frame = cellFrameDst;
    
    if (animated)
    {
        [UIView commitAnimations];
    }
    
}


- (void)onSwipeLeftStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
//    [self.buttonDelete removeFromSuperview];
//    self.buttonDelete = nil;
}



- (void)onDeleteRequest:(id)sender
{
//    [gEditingSongs removeObjectForKey:self.song.name];
//    
//    if (_deletingTarget == nil)
//        return;
//    
//    [_deletingTarget performSelector:_deletingAction withObject:self withObject:self.song];
}










- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
    
	[super setSelected:selected animated:animated];
    
	// Configure the view for the selected state
}



- (void)willMoveToSuperview:(UIView *)newSuperview 
{
    [super willMoveToSuperview:newSuperview];
    if(!newSuperview) 
    {
        [self.avatar releaseCache];
    }
}





@end




