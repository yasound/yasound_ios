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
#import "ActivityAlertView.h"

@implementation RadioViewCell

@synthesize cellView;
@synthesize cellViewX;
@synthesize avatar;
@synthesize avatarMask;
@synthesize avatarInteractiveView;
@synthesize date;
@synthesize user;
@synthesize message;
@synthesize wallEvent;
@synthesize indexPath;

@synthesize delegate;
@synthesize actionAvatarClick;
@synthesize actionEditing;
@synthesize actionDelete;

@synthesize buttonSpam;
@synthesize buttonTrash;
@synthesize offset;


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


- (void)dealloc
{
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier ownRadio:(BOOL)ownRadio event:(WallEvent*)ev indexPath:(NSIndexPath*)indexPath
{
    self = [super initWithFrame:frame reuseIdentifier:CellIdentifier];
    if (self) 
    {
        _ownRadio = ownRadio;
        _interactiveZoneSize = (_ownRadio)? 2 * INTERACTIVE_ZONE_SIZE : 1 * INTERACTIVE_ZONE_SIZE;
        
        self.wallEvent = ev;
        self.indexPath = indexPath;
        
        BundleStylesheet* sheet = nil;
        
        sheet = [[Theme theme] stylesheetForKey:@"Wall.cellMessage.message" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIFont* messageFont = [sheet makeFont];
        CGFloat messageWidth = sheet.frame.size.width;

        
        assert([ev isTextHeightComputed]);
        assert([ev isCellHeightComputed]);
        CGFloat COMPUTED_HEIGHT = [ev getTextHeight];
        CGFloat CELL_HEIGHT = [ev getCelltHeight];

        
        self.backgroundColor = [UIColor colorWithRed:242.f/255.f green:242.f/255.f blue:245.f/255.f alpha:1];

        sheet = [[Theme theme] stylesheetForKey:@"Wall.cellMessage.background" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.gradient = [sheet makeImage];
        CGRect frame = CGRectMake(0, CELL_HEIGHT - self.gradient.frame.size.height, self.gradient.frame.size.width, self.gradient.frame.size.height);
        self.gradient.frame = frame;
        
        [self addSubview:self.gradient];

        
        sheet = [[Theme theme] stylesheetForKey:@"Wall.cellMessage.background" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        CGRect cellFrame = self.bounds;

        UIView* cellView = [[UIView alloc] initWithFrame:cellFrame];
        self.cellView = cellView;
        self.cellView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.cellView];
        [cellView release];

        
        // avatar
        sheet = [[Theme theme] stylesheetForKey:@"Wall.cellMessage.avatar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.avatar = [[WebImageView alloc] initWithImageAtURL:[[YasoundDataProvider main] urlForPicture:ev.user_picture]];
        self.avatar.frame = sheet.frame;
        [self.cellView addSubview:self.avatar];
        
        // set target from parent
        self.avatarInteractiveView = [[InteractiveView alloc] initWithFrame:sheet.frame target:self action:@selector(onAvatarClicked:)];
        [self.cellView addSubview:self.avatarInteractiveView];
        
        // draw circle mask
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = 22;

        // avatar circled mask
        sheet = [[Theme theme] stylesheetForKey:@"Wall.cellMessage.avatarMask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.avatarMask = [[UIImageView alloc] initWithImage:[sheet image]];
        self.avatarMask.frame = sheet.frame;
        [self.cellView addSubview:self.avatarMask];
        
        
        
        // date
        sheet = [[Theme theme] stylesheetForKey:@"Wall.cellMessage.date" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.date = [sheet makeLabel];
        self.date.text = [self dateToString:ev.start_date];
        [self.cellView addSubview:self.date];
        
        // user
        sheet = [[Theme theme] stylesheetForKey:@"Wall.cellMessage.user" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.user = [sheet makeLabel];
        self.user.text = ev.user_name;
        [self.cellView addSubview:self.user];

        // message background
        BundleStylesheet* messageSheet = [[Theme theme] stylesheetForKey:@"Wall.cellMessage.message" retainStylesheet:YES overwriteStylesheet:NO error:nil];

        
        // message
        self.message = [messageSheet makeLabel];
        self.message.text = ev.text;
        
        [self.message setLineBreakMode:UILineBreakModeWordWrap];
        [self.message setNumberOfLines:0];        
        [self.cellView addSubview:self.message];
        
        self.message.frame = CGRectMake(self.message.frame.origin.x, self.message.frame.origin.y, self.message.frame.size.width, COMPUTED_HEIGHT);
        
        
        
        
        UISwipeGestureRecognizer* swipeRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight)] autorelease];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipeRight];
        
        UISwipeGestureRecognizer* swipeLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeLeft)] autorelease];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipeLeft];

    }
    return self;
}



- (void)update:(WallEvent*)ev indexPath:(NSIndexPath*)indexPath
{
    assert([ev isTextHeightComputed]);
    assert([ev isCellHeightComputed]);
    CGFloat COMPUTED_HEIGHT = [ev getTextHeight];
    CGFloat CELL_HEIGHT = [ev getCelltHeight];
    

    
    self.wallEvent = ev;
    self.indexPath = indexPath;

    self.gradient.frame = CGRectMake(0, CELL_HEIGHT - self.gradient.frame.size.height, self.gradient.frame.size.width, self.gradient.frame.size.height);

    self.date.text = [self dateToString:ev.start_date];
    self.user.text = ev.user_name;
    self.message.text = ev.text;
    
    self.message.frame = CGRectMake(self.message.frame.origin.x, self.message.frame.origin.y, self.message.frame.size.width, COMPUTED_HEIGHT);
    
    [self.avatar releaseCache];
    [self.avatar setUrl:[[YasoundDataProvider main] urlForPicture:ev.user_picture]];
    
    if ([self.wallEvent editing])
        [self activateEditModeAnimated:NO];
    else
        [self deactivateEditModeAnimated:NO silent:YES];
    
}


- (void)onAvatarClicked:(id)sender
{
    if (self.delegate == nil)
        return;
    
    [self.delegate performSelector:self.actionAvatarClick withObject:self];
}














-(void)onPan:(UIPanGestureRecognizer *)gesture;
{
    UIView *piece = [gesture view];
    
    [self initEditView];
    
    if ([gesture state] == UIGestureRecognizerStateBegan)
        self.cellViewX = self.cellView.frame.origin.x;
        
    CGPoint translation = [gesture translationInView:self];

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

        if (![self.wallEvent editing])
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


- (void)initEditView
{
    BundleStylesheet* sheet;
    
    
    // button spam
    sheet = [[Theme theme] stylesheetForKey:@"Wall.Moderation.CellModerIconSpam" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.buttonSpam = [sheet makeButton];
    CGFloat buttonPos = self.cellView.frame.size.width;
    self.buttonSpam.frame = CGRectMake(buttonPos, self.cellView.frame.size.height/2.f - self.buttonSpam.frame.size.height/2.f, self.buttonSpam.frame.size.width, self.buttonSpam.frame.size.height);
    [self.cellView addSubview:self.buttonSpam];

    buttonPos += self.buttonSpam.frame.size.width;
    
    if (_ownRadio)
    {
        // button trash
        sheet = [[Theme theme] stylesheetForKey:@"Wall.Moderation.CellModerIconTrash" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.buttonTrash = [sheet makeButton];
        self.buttonTrash.frame = CGRectMake(buttonPos, self.cellView.frame.size.height/2.f - self.buttonTrash.frame.size.height/2.f, self.buttonTrash.frame.size.width, self.buttonTrash.frame.size.height);
        [self.cellView addSubview:self.buttonTrash];
    }
    
}





- (void)onSwipeLeft
{
    if ([self.wallEvent editing])
        return;
    

    [self activateEditModeAnimated:YES];
    
}

- (void)onSwipeRight
{
    if (![self.wallEvent editing])
        return;

    [self deactivateEditModeAnimated:YES];
}




static const CGFloat kSpringRestingHeight = 4;

- (void)activateEditModeAnimated:(BOOL)animated
{
    [self.wallEvent setEditing:YES];
    if ((self.delegate != nil) && (self.actionEditing != nil))
        [self.delegate performSelector:self.actionEditing withObject:self withObject:[NSNumber numberWithBool:YES]];
    
    
    [self initEditView];
    
    self.offset = _interactiveZoneSize;
    
    CGRect cellFrameDst = CGRectMake(0 - _interactiveZoneSize, self.cellView.frame.origin.y, self.cellView.frame.size.width, self.cellView.frame.size.height);
    
    if (animated)
    {
        [self bounceAnimationTo:cellFrameDst endAction:nil];
    }
    else
    {
        self.cellView.frame = cellFrameDst;
    }
}



- (void)deactivateEditModeAnimated:(BOOL)animated
{
    [self deactivateEditModeAnimated:animated silent:NO];
}



- (void)deactivateEditModeAnimated:(BOOL)animated silent:(BOOL)silent
{
    [self.wallEvent setEditing:NO];
    
    if (!silent && (self.delegate != nil) && (self.actionEditing != nil))
        [self.delegate performSelector:self.actionEditing withObject:self withObject:[NSNumber numberWithBool:NO]];
    
    CGRect cellFrameDst = CGRectMake(0, self.cellView.frame.origin.y, self.cellView.frame.size.width, self.cellView.frame.size.height);
    
    
    if (animated)
    {
        [self bounceAnimationTo:cellFrameDst endAction:@selector(bounceAnimationDidEnd:finished:context:)];
    }
    else
    {
        self.cellView.frame = cellFrameDst;
        [self bounceAnimationDidEnd:nil finished:nil context:NULL];
    }
    
    self.buttonSpam = nil;
    self.buttonTrash = nil;
}




- (void) bounceAnimationTo:(CGRect)destFrame endAction:(SEL)endAction
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ANIMATION_DURATION];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    if (endAction != nil)
    {
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:endAction];
    }
    self.cellView.frame = destFrame;
    [UIView commitAnimations];

    CABasicAnimation *bounceAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    bounceAnimation.duration = ANIMATION_DURATION;
    bounceAnimation.fromValue = [NSNumber numberWithInt:0];
    bounceAnimation.toValue = [NSNumber numberWithInt:10];
    bounceAnimation.repeatCount = 2;
    bounceAnimation.autoreverses = YES;
    bounceAnimation.fillMode = kCAFillModeForwards;
    bounceAnimation.removedOnCompletion = NO;
    bounceAnimation.additive = YES;
    [self.cellView.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
}


- (void)bounceAnimationDidEnd:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
}


- (void)onSwipeLeftStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
}



- (void)onDeleteRequest:(id)sender
{
}







- (void)onModerSpam:(id)sender
{
    NSString* title = NSLocalizedString(@"RadioViewCell_moderation_spam_title", nil);
    NSString* message = NSLocalizedString(@"RadioViewCell_moderation_spam_message", nil);
    NSString* button = NSLocalizedString(@"RadioViewCell_moderation_spam_button", nil);
    
    _alertSpam = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Navigation_cancel", nil) otherButtonTitles:button, nil];
    [_alertSpam show];
    [_alertSpam release];  

}


- (void)onModerKick:(id)sender
{
    
}


- (void)onModerTrash:(id)sender
{
    NSString* title = NSLocalizedString(@"RadioViewCell_moderation_trash_title", nil);
    NSString* message = NSLocalizedString(@"RadioViewCell_moderation_trash_message", nil);
    NSString* button = NSLocalizedString(@"RadioViewCell_moderation_trash_button", nil);
    
    _alertTrash = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Navigation_cancel", nil) otherButtonTitles:button, nil];
    [_alertTrash show];
    [_alertTrash release];  
}



#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self deactivateEditModeAnimated:YES];
    if (self.buttonSpam)
        self.buttonSpam.selected = NO;
    if (self.buttonTrash)
        self.buttonTrash.selected = NO;


    if ((alertView == _alertTrash) && (buttonIndex == 1))
    {
        // send delete request to server
        [[YasoundDataProvider main] moderationDeleteWallMessage:self.wallEvent.id];
        
        // delete locally 
        if (self.actionDelete != nil)
            [self.delegate performSelector:self.actionDelete withObject:self];
        return;
    }

    if ((alertView == _alertSpam) && (buttonIndex == 1))
    {
        [[YasoundDataProvider main] moderationReportAbuse:self.wallEvent.id];
        
        NSString* message = NSLocalizedString(@"RadioViewCell_moderation_spam_confirm", nil);
        [ActivityAlertView showWithTitle:message closeAfterTimeInterval:2];

        
        return;
    }

    if ((alertView == _alertKick) && (buttonIndex == 1))
    {
        return;
    }
}





- (BOOL)touch:(CGPoint)touchCoordinates
{
    CGPoint realPoint = CGPointMake(touchCoordinates.x + self.offset, touchCoordinates.y);
    
    BOOL spam = CGRectContainsPoint(self.buttonSpam.frame, realPoint);
    if (spam)
    {
        self.buttonSpam.selected = YES;
        [self onModerSpam:nil];
        return YES;
    }

    if (!self.buttonTrash)
        return NO;
    
    BOOL trash = CGRectContainsPoint(self.buttonTrash.frame, realPoint);
    if (trash)
    {
        self.buttonTrash.selected = YES;
        [self onModerTrash:nil];
        return YES;
    }

    return NO;
}












- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
    
	[super setSelected:selected animated:animated];
    
	// Configure the view for the selected state
}



@end




