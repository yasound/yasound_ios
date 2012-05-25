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
@synthesize date;
@synthesize user;
@synthesize message;
@synthesize messageBackground;
@synthesize separator;
@synthesize cellEditView;
@synthesize wallEvent;

@synthesize delegate;
@synthesize actionAvatarClick;
@synthesize actionEditing;



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


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier ownRadio:(BOOL)ownRadio event:(WallEvent*)ev indexPath:(NSIndexPath*)indexPath
{
    self = [super initWithFrame:frame reuseIdentifier:CellIdentifier];
    if (self) 
    {
        _ownRadio = ownRadio;
        _interactiveZoneSize = (_ownRadio)? 3 * INTERACTIVE_ZONE_SIZE : 1 * INTERACTIVE_ZONE_SIZE;
        
        self.wallEvent = ev;
        
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

//        UIPanGestureRecognizer* pan = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)] autorelease];
//        pan.maximumNumberOfTouches = 2;
//        pan.minimumNumberOfTouches = 1;
//        pan.delegate = self;
//        [self addGestureRecognizer:pan];
//
        

    }
    return self;
}




//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    
//}


- (void)update:(WallEvent*)ev indexPath:(NSIndexPath*)indexPath
{
    assert([ev isTextHeightComputed] == YES);
    
    self.wallEvent = ev;

    CGFloat height = [ev getTextHeight];
    
    self.date.text = [self dateToString:ev.start_date];
    self.user.text = ev.user_name;
    self.message.text = ev.text;
    
    self.messageBackground.frame = CGRectMake(self.messageBackground.frame.origin.x, self.messageBackground.frame.origin.y, self.messageBackground.frame.size.width, height + 2 * MESSAGE_SPACING);
    
    self.message.frame = CGRectMake(self.message.frame.origin.x, self.message.frame.origin.y, self.message.frame.size.width, height);
    
    self.separator.frame = CGRectMake(0, height + THE_REST_OF_THE_CELL_HEIGHT - 2, self.separator.frame.size.width, self.separator.frame.size.height);
    
    [self.avatar setUrl:[[YasoundDataProvider main] urlForPicture:ev.user_picture]];
    
//    if ([self.wallEvent editing])
//        [self activateEditModeAnimated:NO];
//    else
//        [self deactivateEditModeAnimated:NO];
    
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
    if (self.cellEditView != nil)
        return;
    
    CGRect frame = CGRectMake(self.bounds.size.width - _interactiveZoneSize, 0, _interactiveZoneSize, self.bounds.size.height);

    UIView* view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
    [self addSubview:view];
    [self bringSubviewToFront:self.cellView];
    self.cellEditView = view;
    
    
    // shadow top
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"CellModerShadowTop" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIView* shadowTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, sheet.frame.size.height)];
    shadowTop.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
    [self.cellEditView addSubview:shadowTop];
    [shadowTop release];

    // shadow bottom
    sheet = [[Theme theme] stylesheetForKey:@"CellModerShadowBottom" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIView* shadowBottom = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height - sheet.frame.size.height, view.frame.size.width, sheet.frame.size.height)];
    shadowBottom.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
    [self.cellEditView addSubview:shadowBottom];
    [shadowBottom release];

//    // shadow left on cellView
//    sheet = [[Theme theme] stylesheetForKey:@"CellModerShadowLeft" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    UIView* shadowLeft = [[UIView alloc] initWithFrame:CGRectMake(self.cellView.frame.size.width, 0, sheet.frame.size.width, self.cellView.frame.size.height)];
//    shadowLeft.backgroundColor = [UIColor clearColor];
//    [self.cellView addSubview:shadowLeft];
//    UIView* imageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, shadowLeft.frame.size.width, shadowLeft.frame.size.height)];
//    imageView.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
//    [shadowTop addSubview:imageView];
//    [shadowLeft release];
//    [imageView release];
    
    
    
    
    // button spam
    sheet = [[Theme theme] stylesheetForKey:@"CellModerIconSpam" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIButton* button = [sheet makeButton];
    [button addTarget:self action:@selector(onModerSpam:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(self.cellEditView.frame.size.width - INTERACTIVE_ZONE_SIZE + (INTERACTIVE_ZONE_SIZE/2.f - button.frame.size.width/2.f), self.cellEditView.frame.size.height/2.f - button.frame.size.height/2.f, button.frame.size.width, button.frame.size.height);
    [self.cellEditView addSubview:button];
    [button release];

    // button kick
    sheet = [[Theme theme] stylesheetForKey:@"CellModerIconKick" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    button = [sheet makeButton];
    [button addTarget:self action:@selector(onModerKick:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(self.cellEditView.frame.size.width - 2*INTERACTIVE_ZONE_SIZE + (INTERACTIVE_ZONE_SIZE/2.f - button.frame.size.width/2.f), self.cellEditView.frame.size.height/2.f - button.frame.size.height/2.f, button.frame.size.width, button.frame.size.height);
    [self.cellEditView addSubview:button];
    [button release];

    // button trash
    sheet = [[Theme theme] stylesheetForKey:@"CellModerIconTrash" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    button = [sheet makeButton];
    [button addTarget:self action:@selector(onModerTrash:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(self.cellEditView.frame.size.width - 3*INTERACTIVE_ZONE_SIZE + (INTERACTIVE_ZONE_SIZE/2.f - button.frame.size.width/2.f), self.cellEditView.frame.size.height/2.f - button.frame.size.height/2.f, button.frame.size.width, button.frame.size.height);
    [self.cellEditView addSubview:button];
    [button release];
    
    [view release];
    
    
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

    // [self initEditView];

    [self deactivateEditModeAnimated:YES];
}




static const CGFloat kSpringRestingHeight = 4;

- (void)activateEditModeAnimated:(BOOL)animated
{
    //    if ([self.wallEvent editing])
    //        return;
    
    [self.wallEvent setEditing:YES];
    if ((self.delegate != nil) && (self.actionEditing != nil))
        [self.delegate performSelector:self.actionEditing withObject:self withObject:[NSNumber numberWithBool:YES]];
    
    
    [self initEditView];
    
    
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
    //    if (!self.wallEvent.editing)
    //        return;
    
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
}




//- (void) bounceAnimationTo:(CGFloat)destX
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
    if (self.cellEditView != nil)
    {
        [self.cellEditView removeFromSuperview];
        self.cellEditView = nil;
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
    if ((alertView == _alertTrash) && (buttonIndex == 1))
    {
        [[YasoundDataProvider main] moderationDeleteWallMessage:self.wallEvent.id];
        return;
    }

    if ((alertView == _alertSpam) && (buttonIndex == 1))
    {
        [[YasoundDataProvider main] moderationReportAbuse:self.wallEvent.id];
        
        [self deactivateEditModeAnimated:YES];
        
        NSString* message = NSLocalizedString(@"RadioViewCell_moderation_spam_confirm", nil);
        [[ActivityAlertView main] showWithTitle:message closeAfterTimeInterval:2];

        
        return;
    }

    if ((alertView == _alertKick) && (buttonIndex == 1))
    {
        return;
    }
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




