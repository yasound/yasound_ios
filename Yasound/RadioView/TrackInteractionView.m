//
//  TrackInteractionView.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "TrackInteractionView.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "YasoundDataProvider.h"
#import "ActivityAlertView.h"
#import "SessionManager.h"
#import "YasoundSessionManager.h"
#import "ActivityModelessSpinner.h"
#import "BuyLinkManager.h"
#import "AudioStreamManager.h"
#import "YasoundAppDelegate.h"



@implementation TrackInteractionView

@synthesize shareFullMessage;
@synthesize shareButtons;

- (id)initWithSong:(Song*)song
{
  assert(song != nil);
    if (self = [super init])
    {
        _song = song;
        [_song retain];
        _sharingFacebook = NO;
        _sharingTwitter = NO;
        
      _buttonLikedClickedTarget = nil;
      _buttonLikedClickedAction = nil;
        
//        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TrackInteraction" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//        
//        CGRect frame = CGRectMake(0, 0, sheet.frame.size.width, sheet.frame.size.height);
//        self.frame = frame;
        
        UIButton* btn  = nil;
        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TrackInteractionButtonBuy" error:nil];
        UIImage* image = [UIImage imageNamed:@"btnBuyUp.png"];
        UIImage* imageHighlighted = [UIImage imageNamed:@"btnBuyDown.png"];
        btn = [[UIButton alloc] initWithFrame:CGRectMake(sheet.frame.origin.x, sheet.frame.origin.y, image.size.width, image.size.height)];
        [btn setImage:image forState:UIControlStateNormal];
        [btn setImage:imageHighlighted forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(onTrackBuy:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];

        sheet = [[Theme theme] stylesheetForKey:@"TrackInteractionButtonLike" error:nil];
        btn = [sheet makeButton];
        [btn addTarget:self action:@selector(onTrackLike:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        


        
//        sheet = [[Theme theme] stylesheetForKey:@"TrackInteractionButtonAdd" error:nil];
//        btn = [sheet makeButton];
//        [btn addTarget:self action:@selector(onTrackAdd:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:btn];

        sheet = [[Theme theme] stylesheetForKey:@"TrackInteractionButtonShare" error:nil];
        btn = [sheet makeButton];
        [btn addTarget:self action:@selector(onTrackShare:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];

        
    }
    
    return self;
}


- (void)dealloc
{
    [_song release];
    [super dealloc];
}


- (void)setButtonLikeClickedTarget:(id)target action:(SEL)action
{
  _buttonLikedClickedTarget = target;
  _buttonLikedClickedAction = action;
}

#define SPINNER_DELAY 1.5f

- (void)onTrackLike:(id)sender
{
    [[YasoundDataProvider main] setMood:eMoodLike forSong:_song];
    [[ActivityModelessSpinner main] addRefForTimeInterval:SPINNER_DELAY];
    //[ActivityAlertView showWithTitle:NSLocalizedString(@"RadioView_track_like", nil) closeAfterTimeInterval:ACTIVITYALERT_TIMEINTERVAL];
  
  if (_buttonLikedClickedTarget && _buttonLikedClickedAction)
    [_buttonLikedClickedTarget performSelector:_buttonLikedClickedAction];
}

- (void)onTrackDislike:(id)sender
{
    [[YasoundDataProvider main] setMood:eMoodDislike forSong:_song];
//    [ActivityAlertView showWithTitle:NSLocalizedString(@"RadioView_track_dislike", nil) closeAfterTimeInterval:ACTIVITYALERT_TIMEINTERVAL];
    [[ActivityModelessSpinner main] addRefForTimeInterval:SPINNER_DELAY];
}

- (void)onTrackAdd:(id)sender
{
    [[YasoundDataProvider main] addSongToUserRadio:_song];
//    [ActivityAlertView showWithTitle:NSLocalizedString(@"RadioView_track_add", nil) closeAfterTimeInterval:ACTIVITYALERT_TIMEINTERVAL];
    [[ActivityModelessSpinner main] addRefForTimeInterval:SPINNER_DELAY];
}

- (NSString *)getUserCountry
{
    NSLocale *locale = [NSLocale currentLocale];
    return [locale objectForKey: NSLocaleCountryCode];
}

- (void)onTrackBuy:(id)sender
{
    BuyLinkManager *mgr = [[BuyLinkManager alloc] init];
    NSString *link = [mgr generateLink:_song.artist 
                                 album:_song.album 
                                  song:_song.name];
    
    if (!link) 
    {
        // let's retry without album
        link = [mgr generateLink:_song.artist 
                           album:@""
                            song:_song.name];
    }
    [mgr release];
    
    if (link) 
    {
        NSURL *url = [[NSURL alloc] initWithString:link];
        [[UIApplication sharedApplication] openURL:url];
        [url release];
    }
    else
    {
      UIAlertView *av = nil;
      av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UnableToFindSongOniTunes_Title", nil) 
                                     message:NSLocalizedString(@"UnableToFindSongOniTunes_Message", nil) 
                                    delegate:nil 
                           cancelButtonTitle:NSLocalizedString(@"UnableToFindSongOniTunes_OK", nil) 
                           otherButtonTitles:nil];
      
      [av show];
      [av release];  
    }
  
}


#define TIMEOUT_FOR_SHARING 8

- (void)onTrackShare:(id)sender
{
    Radio *currentRadio = [AudioStreamManager main].currentRadio;

    NSString* message = NSLocalizedString(@"RadioView_track_share_message", nil);
    self.shareFullMessage = [NSString stringWithFormat:message, _song.name, _song.artist, currentRadio.name];
    message = [NSString stringWithFormat: NSLocalizedString(@"ShareTrackOnFacebookAlertMessage", nil), self.shareFullMessage];
    
    UIActionSheet* popupQuery = [[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:NSLocalizedString(@"SettingsView_saveOrCancel_cancel", nil) destructiveButtonTitle:nil otherButtonTitles:nil];
    
    self.shareButtons = [[NSMutableDictionary alloc] init];
    
    BOOL facebook = ([YasoundDataProvider main].user.facebook_uid != nil);
    BOOL twitter = ([YasoundDataProvider main].user.twitter_uid != nil);
    BOOL yasound = ([YasoundDataProvider main].user.yasound_email != nil);
    
    if (facebook)
    {
        NSInteger index = [popupQuery addButtonWithTitle: NSLocalizedString(@"RadioView_track_share_facebook", nil)];
        [self.shareButtons setObject:LOGIN_TYPE_FACEBOOK forKey:[NSString stringWithFormat:@"%d", index]];
    }
    
    if (twitter)
    {
        NSInteger index = [popupQuery addButtonWithTitle: NSLocalizedString(@"RadioView_track_share_twitter", nil)];
        [self.shareButtons setObject:LOGIN_TYPE_TWITTER forKey:[NSString stringWithFormat:@"%d", index]];
    }
    
    //LBDEBUG
    NSLog(@"self.shareButtons %@", self.shareButtons);

//    if (yasound)
//    {
//        NSInteger index = [popupQuery addButtonWithTitle: NSLocalizedString(@"RadioView_track_share_yasound", nil)];
//        [self.shareButtons setObject:LOGIN_TYPE_FACEBOOK forKey:[NSString stringWithFormat:@"%d", index]];
//    }

    
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [popupQuery showInView:self];
    [popupQuery release];
}


#pragma mark - ActionSheet Delegate


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    if (buttonIndex == 0)
        return;
    
    Radio *currentRadio = [AudioStreamManager main].currentRadio;
    
    NSString* buttonIdentifier = [self.shareButtons objectForKey:[NSString stringWithFormat:@"%d", buttonIndex]];

    BOOL shareFacebook = ([buttonIdentifier isEqualToString:LOGIN_TYPE_FACEBOOK]);
    BOOL shareTwitter = ([buttonIdentifier isEqualToString:LOGIN_TYPE_TWITTER]);
    BOOL shareYasound = ([buttonIdentifier isEqualToString:LOGIN_TYPE_YASOUND]);
    
    NSString* title = NSLocalizedString(@"Yasound share", nil);

    
    NSURL* pictureURL = [[NSURL alloc] initWithString:[APPDELEGATE getServerUrlWith:@"fr/images/logo.png"]];
    NSString* link = [APPDELEGATE getServerUrlWith:@"listen/%@"];
    NSURL* fullLink = [[NSURL alloc] initWithString:[NSString stringWithFormat:link,
                                                     currentRadio.uuid]];

    if (shareFacebook)
    {
        [[YasoundDataProvider main] radioHasBeenShared:currentRadio];
        _sharingFacebook = YES;
        
        NSLog(@"postMessageForFacebook : %@", self.shareFullMessage);
        NSLog(@"pictureURL : %@", [pictureURL absoluteString]);
        NSLog(@"link : %@", [fullLink absoluteString]);
        
        [[YasoundSessionManager main] postMessageForFacebook:self.shareFullMessage title:title picture:pictureURL link:fullLink target:self action:@selector(onPostMessageFinished:)];

        return;
    }

    if (shareTwitter)
    {
        [[YasoundDataProvider main] radioHasBeenShared:currentRadio];
        _sharingTwitter = YES;
        
        NSLog(@"postMessageForTwitter : %@", self.shareFullMessage);
        NSLog(@"pictureURL : %@", [pictureURL absoluteString]);
        NSLog(@"link : %@", [fullLink absoluteString]);

      NSString* msg = [NSString stringWithFormat:@"#yasound %@ %@ ", [fullLink absoluteString], self.shareFullMessage];
      
        [[YasoundSessionManager main] postMessageForTwitter:msg title:title picture:pictureURL target:self action:@selector(onPostMessageFinished:)];

        return;
    }

//    if (shareYasound)
//    {
//        _sharingTwitter = YES;
//        
//        NSLog(@"postMessageForTwitter : %@", self.shareFullMessage);
//        NSLog(@"pictureURL : %@", [pictureURL absoluteString]);
//        NSLog(@"link : %@", [fullLink absoluteString]);
//        
//        [[YasoundSessionManager main] postMessageForTwitter:self.shareFullMessage title:title picture:pictureURL target:self action:@selector(onPostMessageFinished:)];
//        
//        return;
//    }
    
    
    [pictureURL release];
    [fullLink release];
}



- (void)onPostMessageFinished:(NSNumber*)finished
{
    BOOL done = [finished boolValue];
    
    NSLog(@"onPostMessageFinished received");
    
    if (!done)
    {
        UIAlertView *av;
        
        if (_sharingFacebook)
            av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RadioView_track_share_error", nil) message:NSLocalizedString(@"RadioView_track_share_facebook_error", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        else if (_sharingTwitter)
            av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RadioView_track_share_error", nil) message:NSLocalizedString(@"RadioView_track_share_twitter_error", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
        _sharingFacebook = NO;
        _sharingTwitter = NO;
        
        [av show];
        [av release];  
        return;    
    }
}




//#pragma mark - touches actions




//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
//{
//    UITouch *aTouch = [touches anyObject];
//    
//    if (aTouch.tapCount == 2) 
//    
//}
//



//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
//{
//    
//}



//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
//{
//    UITouch *theTouch = [touches anyObject];
//    [_target performSelector:_action];
//}




@end

