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


@implementation TrackInteractionView


- (id)initWithSong:(Song*)song
{
    if (self = [super init])
    {
        _song = song;
        [_song retain];
        _sharing = NO;
        
//        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TrackInteraction" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//        
//        CGRect frame = CGRectMake(0, 0, sheet.frame.size.width, sheet.frame.size.height);
//        self.frame = frame;
        
        UIButton* btn  = nil;
        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TrackInteractionButtonLike" error:nil];
        btn = [sheet makeButton];
        [btn addTarget:self action:@selector(onTrackLike:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        sheet = [[Theme theme] stylesheetForKey:@"TrackInteractionButtonDislike" error:nil];
        btn = [sheet makeButton];
        [btn addTarget:self action:@selector(onTrackDislike:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];

        sheet = [[Theme theme] stylesheetForKey:@"TrackInteractionButtonAdd" error:nil];
        btn = [sheet makeButton];
        [btn addTarget:self action:@selector(onTrackAdd:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];

        sheet = [[Theme theme] stylesheetForKey:@"TrackInteractionButtonBuy" error:nil];
        btn = [sheet makeButton];
        [btn addTarget:self action:@selector(onTrackBuy:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];

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


- (void)onTrackLike:(id)sender
{
    [[YasoundDataProvider main] setMood:eMoodLike forSong:_song];
    // ICI
    [ActivityAlertView showWithTitle:NSLocalizedString(@"RadioView_track_like", nil) closeAfterTimeInterval:ACTIVITYALERT_TIMEINTERVAL];
}

- (void)onTrackDislike:(id)sender
{
    [[YasoundDataProvider main] setMood:eMoodDislike forSong:_song];
    [ActivityAlertView showWithTitle:NSLocalizedString(@"RadioView_track_dislike", nil) closeAfterTimeInterval:ACTIVITYALERT_TIMEINTERVAL];
}

- (void)onTrackAdd:(id)sender
{
    [[YasoundDataProvider main] addSongToUserRadio:_song];
    [ActivityAlertView showWithTitle:NSLocalizedString(@"RadioView_track_add", nil) closeAfterTimeInterval:ACTIVITYALERT_TIMEINTERVAL];
}

- (NSString *)getUserCountry
{
    NSLocale *locale = [NSLocale currentLocale];
    return [locale objectForKey: NSLocaleCountryCode];
}

- (void)onTrackBuy:(id)sender
{
//    NSString* buyString = @"itms://phobos.apple.com/WebObjects/MZSearch.woa/wa/com.apple.jingle.search.DirectAction/search?artist=Prince";

//    NSString* buyString = @"itms://phobos.apple.com/WebObjects/MZSearch.woa/wa/advancedSearchResults?artistTerm
//    
//    NSURL* url = [[NSURL alloc] initWithString:[buyString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
//    [[UIApplication sharedApplication] openURL:url];
//    [url release];
}


#define TIMEOUT_FOR_SHARING 8

- (void)onTrackShare:(id)sender
{
    NSString* message = @"message_test2";
    NSString* title = @"title_test2";
    NSURL* pictureURL = nil;
    
    
    if ([[YasoundSessionManager main].loginType isEqualToString:LOGIN_TYPE_FACEBOOK])
    {
        _sharing = YES;
        [ActivityAlertView showWithTitle:NSLocalizedString(@"RadioView_track_share_facebook", nil)];
        [NSTimer scheduledTimerWithTimeInterval:TIMEOUT_FOR_SHARING target:self selector:@selector(onSharingTimeout:) userInfo:nil repeats:NO];

        [[YasoundSessionManager main] postMessageForFacebook:message title:title picture:pictureURL target:self action:@selector(onPostMessageFinished:)];
    }

    else if ([[YasoundSessionManager main].loginType isEqualToString:LOGIN_TYPE_TWITTER])
    {
        _sharing = YES;
        [ActivityAlertView showWithTitle:NSLocalizedString(@"RadioView_track_share_twitter", nil)];
        [NSTimer scheduledTimerWithTimeInterval:TIMEOUT_FOR_SHARING target:self selector:@selector(onSharingTimeout:) userInfo:nil repeats:NO];

        [[YasoundSessionManager main] postMessageForTwitter:message title:title picture:pictureURL target:self action:@selector(onPostMessageFinished:)];
    }
    
    //    NSString* buyString = @"itms://phobos.apple.com/WebObjects/MZSearch.woa/wa/com.apple.jingle.search.DirectAction/search?artist=Prince";
    
    //    NSString* buyString = @"itms://phobos.apple.com/WebObjects/MZSearch.woa/wa/advancedSearchResults?artistTerm
    //    
    //    NSURL* url = [[NSURL alloc] initWithString:[buyString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    //    [[UIApplication sharedApplication] openURL:url];
    //    [url release];
}



- (void)onSharingTimeout:(NSTimer*)timer
{
    if (_sharing)
    {
        _sharing = NO;
        [ActivityAlertView close];
        // don't say anything since we don't why the postMessage request did not callback
    }
}

- (void)onPostMessageFinished:(NSNumber*)finished
{
    if (!_sharing)
        return;
    
    _sharing = NO;
    [ActivityAlertView close];
    BOOL done = [finished boolValue];
    
    if (!done)
    {
        UIAlertView *av;
        
        if ([[YasoundSessionManager main].loginType isEqualToString:LOGIN_TYPE_FACEBOOK])
            av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RadioView_track_share_error", nil) message:NSLocalizedString(@"RadioView_track_share_facebook_error", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        else if ([[YasoundSessionManager main].loginType isEqualToString:LOGIN_TYPE_TWITTER])
            av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RadioView_track_share_error", nil) message:NSLocalizedString(@"RadioView_track_share_twitter_error", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
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

