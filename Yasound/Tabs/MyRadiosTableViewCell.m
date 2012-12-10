//
//  MyRadiosTableViewCell.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "MyRadiosTableViewCell.h"
#import "YasoundDataProvider.h"
#import "Theme.h"
#import <QuartzCore/QuartzCore.h>
#import "ActivityAlertView.h"
#import "RootViewController.h"




@implementation MyRadiosTableViewCell

@synthesize delegate;
@synthesize radio;
@synthesize offset;
@synthesize container;

@synthesize image;
@synthesize title;
@synthesize subscribers;
@synthesize listeners;
@synthesize metric1;
@synthesize metric2;
@synthesize metric1sub;
@synthesize metric2Background;
@synthesize buttonDelete;



- (void)awakeFromNib
{
        self.metric1sub.text = NSLocalizedString(@"MyRadios.metric1.sublabel", nil);
    
        UISwipeGestureRecognizer* swipeRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight)] autorelease];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self.container addGestureRecognizer:swipeRight];
        
        UISwipeGestureRecognizer* swipeLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeLeft)] autorelease];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.container addGestureRecognizer:swipeLeft];
    
}



- (void)updateWithRadio:(YaRadio*)aRadio target:(id)target editing:(BOOL)editing
{
    self.radio = aRadio;
    self.delegate = target;

    NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:self.radio.picture];
    [self.image setUrl:imageURL];
    
    // info
    self.title.text = self.radio.name;
    self.subscribers.text = [NSString stringWithFormat:@"%d", [self.radio.favorites integerValue]];
    self.listeners.text = [NSString stringWithFormat:@"%d", [self.radio.nb_current_users integerValue]];

    // metrics
    int seconds = [self.radio.overall_listening_time intValue] / 60;
    self.metric1.text = [NSString stringWithFormat:@"%d", seconds];
    
    NSInteger metric2Int = [self.radio.new_wall_messages_count integerValue];
    if (metric2Int == 0) {
        self.metric2.text = @"0";
        self.metric2.hidden = YES;
        self.metric2Background.hidden = YES;
    }
    else {
        self.metric2.text = [self.radio.new_wall_messages_count stringValue];
        self.metric2.hidden = NO;
        self.metric2Background.hidden = NO;
    }
    
    if (editing)
        [self activateEditModeAnimated:NO];
    else
        [self deactivateEditModeAnimated:NO];
}





- (void)dealloc
{
  [super dealloc];
}




- (IBAction)onRadioClicked:(id)sender
{
    [self.delegate myRadioRequestedPlay:self.radio];
}


- (IBAction)onStatsClicked:(id)sender
{
    [self.delegate myRadioRequestedStats:self.radio];
}

- (IBAction)onSettingsClicked:(id)sender
{
    [self.delegate myRadioRequestedSettings:self.radio];
}


- (IBAction)onProgrammingClicked:(id)sender {
    
    [self.delegate myRadioRequestedProgramming:self.radio];
}


- (IBAction)onMessageClicked:(id)sender {
    
    [self.delegate myRadioRequestedBroadcast:self.radio];
}






- (void)onSwipeLeft
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_MYRADIO_EDIT object:self.radio];

    [self activateEditModeAnimated:YES];
    
}

- (void)onSwipeRight
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_MYRADIO_UNEDIT object:self.radio];

    [self deactivateEditModeAnimated:YES];
}


static const CGFloat kSpringRestingHeight = 4;

- (void)activateEditModeAnimated:(BOOL)animated
{
    self.offset = 80;
    
    CGRect cellFrameDst = CGRectMake(0 - offset, self.container.frame.origin.y, self.container.frame.size.width, self.container.frame.size.height);
    
    if (animated)
    {
        [self bounceAnimationTo:cellFrameDst endAction:@selector(bounceAnimationDidEnd:finished:context:)];
    }
    else
    {
        self.container.frame = cellFrameDst;
    }
}



- (void)deactivateEditModeAnimated:(BOOL)animated
{
    [self deactivateEditModeAnimated:animated silent:NO];
}



- (void)deactivateEditModeAnimated:(BOOL)animated silent:(BOOL)silent
{
    CGRect cellFrameDst = CGRectMake(0, self.container.frame.origin.y, self.container.frame.size.width, self.container.frame.size.height);
    
    
    if (animated)
    {
        [self bounceAnimationTo:cellFrameDst endAction:nil];
    }
    else
    {
        self.container.frame = cellFrameDst;
        [self bounceAnimationDidEnd:nil finished:nil context:NULL];
    }
    
    self.buttonDelete = nil;
}


#define ANIMATION_DURATION 0.1

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
    self.container.frame = destFrame;
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
    [self.container.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
}


- (void)bounceAnimationDidEnd:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self.buttonDelete addTarget:self action:@selector(onDeleteClicked:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)onSwipeLeftStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
}



- (IBAction)onDeleteClicked:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MyRadios.delete.title", nil) message:NSLocalizedString(@"MyRadios.delete.message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Navigation.cancel", nil) otherButtonTitles:NSLocalizedString(@"Navigation.delete", nil), nil];
    [alert show];
    [alert release];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self deactivateEditModeAnimated:YES];
        return;
    }
    
    [ActivityAlertView showWithTitle:nil];
    
    DLog(@"deleteRadio forRadio '%@' name '%@'", self.radio.id, self.radio.name);
    
    [[YasoundDataProvider main] deleteRadio:self.radio withCompletionBlock:^(int status, NSString* response, NSError* error){
        BOOL success = YES;
        if (error)
        {
            DLog(@"delete radio error: %d - %@", error.code, error.domain);
            success = NO;
        }
        else if (status != 200)
        {
            DLog(@"delete radio error: response status %d", status);
            success = NO;
        }
        else
        {
            NSDictionary* dict = [response jsonToDictionary];
            if (!dict || ![dict valueForKey:@"success"])
            {
                DLog(@"delete radio error: bad response %@", response);
                success = NO;
            }
            else
            {
                success = [[dict valueForKey:@"success"] boolValue];
            }
            
        }
        if (!success)
        {
            [ActivityAlertView close];
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MyRadios.delete.title", nil) message:NSLocalizedString(@"MyRadios.delete.error.message", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Navigation.ok", nil) otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
        
        DLog(@"onRadioDelete. server response : %@", response);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_MYRADIO_DELETED object:nil];
    }];
}





@end
