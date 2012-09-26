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
//@synthesize metric2sub;
//@synthesize buttonSettings;
@synthesize metric2Background;
@synthesize buttonDelete;



//+ (UINib*)nib
//{
////    // singleton implementation to get a UINib object
////    static dispatch_once_t pred = 0;
////    __strong static UINib* _sharedNibObject = nil;
////    dispatch_once(&pred, ^{
////        _sharedNibObject = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
////    });
////    return _sharedNibObject;
//    
//    static UINib *nib;
//    static dispatch_once_t once;
//    dispatch_once(&once, ^{
//        nib = [UINib nibWithNibName:@"MyRadiosTableViewCell" bundle:nil];
//    });
//    return nib;
//}
//
//- (NSString *)reuseIdentifier
//{
//    return [[self class] reuseIdentifier];
//}
//
//+ (NSString *)reuseIdentifier
//{
//    // return any identifier you like, in this case the class name
////    return NSStringFromClass([self class]);
//    return (NSString *)@"MyRadiosTableViewCell";
//}

//- (id)initWithOwner:(id)owner target:(id)target radio:(Radio*)radio;
//{
//    UINib* myNib = [[self class] nib];
//    
//    
//    NSArray* myArray = [myNib instantiateWithOwner:owner options:nil];
//    NSLog(@"%@", myArray);
//    id object =  [myArray objectAtIndex:0];
//    
//
//    [self updateWithRadio:radio];
//    
//    return object;
//}


//- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)reuseIdentifier ownRadio:(BOOL)ownRadio event:(WallEvent*)ev indexPath:(NSIndexPath*)indexPath
//{
//    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier])
//    {
- (void)awakeFromNib
{
        self.metric1sub.text = NSLocalizedString(@"MyRadios.metric1.sublabel", nil);
//        self.metric2sub.text = NSLocalizedString(@"MyRadios.metric2.sublabel", nil);
    
        
        UISwipeGestureRecognizer* swipeRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight)] autorelease];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self.container addGestureRecognizer:swipeRight];
        
        UISwipeGestureRecognizer* swipeLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeLeft)] autorelease];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.container addGestureRecognizer:swipeLeft];
    
}
//    }
//
//    return self;
//}



- (void)updateWithRadio:(Radio*)radio target:(id)target editing:(BOOL)editing
{
    self.radio = radio;
    self.delegate = target;

    
    NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:radio.picture];
    [self.image setUrl:imageURL];
    
    // info
    self.title.text = radio.name;
    self.subscribers.text = [NSString stringWithFormat:@"%d", [radio.favorites integerValue]];
    self.listeners.text = [NSString stringWithFormat:@"%d", [radio.nb_current_users integerValue]];

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






- (void)willMoveToSuperview:(UIView *)newSuperview 
{
    [super willMoveToSuperview:newSuperview];
    if(!newSuperview) 
    {
        if (self.image)
            [self.image releaseCache];
    }
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
//    DLog(@"settings clicked for radio : %@", [self.radio toString]);
//    
//
//    _sheetTools = [[UIActionSheet alloc] initWithTitle:self.radio.name delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Radio.sheet.button.programming", nil), NSLocalizedString(@"Radio.sheet.button.broadcast", nil), NSLocalizedString(@"Radio.sheet.button.settings", nil), nil];
//    _sheetTools.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//    [_sheetTools showInView:self.superview];
//    [_sheetTools release];
    [self.delegate myRadioRequestedSettings:self.radio];
}


- (IBAction)onProgrammingClicked:(id)sender {
    
    [self.delegate myRadioRequestedProgramming:self.radio];
}


- (IBAction)onMessageClicked:(id)sender {
    
    [self.delegate myRadioRequestedBroadcast:self.radio];
}





//#pragma mark - ActionSheet Delegate
//
//
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (actionSheet == _sheetTools)
//    {
//        if (buttonIndex == 0)
//        {
//            [self.delegate myRadioRequestedProgramming:self.radio];
//            return;
//        }
//        else if (buttonIndex == 1)
//        {
//            [self.delegate myRadioRequestedBroadcast:self.radio];
//            return;
//        }
//        else if (buttonIndex == 2)
//        {
//            [self.delegate myRadioRequestedSettings:self.radio];
//            return;
//        }
//    }
//}

    













//- (void)initEditView
//{
//    BundleStylesheet* sheet;
//    
//    // button delete
//    sheet = [[Theme theme] stylesheetForKey:@"MyRadios.delete" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    self.buttonDelete = [sheet makeButton];
//    self.buttonDelete.frame = CGRectMake(self.frame.size.width, self.buttonSettings.frame.origin.y, self.buttonDelete.frame.size.width, self.buttonDelete.frame.size.height);
//    [self.container addSubview:self.buttonDelete];
//
//    [self.buttonDelete addTarget:self action:@selector(onButtonDeleteClicked:) forControlEvents:UIControlEventTouchUpInside];
//    
//}




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
    //    if ([self.wallEvent editing])
    //        return;
    
//    [self initEditView];
    
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
    //    if (!self.wallEvent.editing)
    //        return;
    
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
    self.container.frame = destFrame;
    //self.cellEditView.frame = CGRectMake(destFrame.origin.x + destFrame.size.width, self.cellEditView.frame.origin.y, self.cellEditView.frame.size.width, self.cellEditView.frame.size.height);
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
    //    if (self.cellEditView != nil)
    //    {
    //        [self.cellEditView removeFromSuperview];
    //        self.cellEditView = nil;
    //    }
}


- (void)onSwipeLeftStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    //    [self.buttonDelete removeFromSuperview];
    //    self.buttonDelete = nil;
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
    
    [[YasoundDataProvider main] deleteRadio:self.radio target:self action:@selector(onRadioDeleted:success:)];
}




- (void)onRadioDeleted:(ASIHTTPRequest*)req success:(BOOL)success
{
    if (!success)
    {
        [ActivityAlertView close];
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MyRadios.delete.title", nil) message:NSLocalizedString(@"MyRadios.delete.error.message", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Navigation.ok", nil) otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    DLog(@"onRadioDelete. server response : %@", req.responseString);

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_MYRADIO_DELETED object:nil];
}





@end
