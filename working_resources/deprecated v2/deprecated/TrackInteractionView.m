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

@synthesize shareButton;
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
        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Wall.Tracks.TrackInteractionButtonBuy" error:nil];
        UIImage* image = [UIImage imageNamed:@"btnBuyUp.png"];
        UIImage* imageHighlighted = [UIImage imageNamed:@"btnBuyDown.png"];
        btn = [[UIButton alloc] initWithFrame:CGRectMake(sheet.frame.origin.x, sheet.frame.origin.y, image.size.width, image.size.height)];
        [btn setImage:image forState:UIControlStateNormal];
        [btn setImage:imageHighlighted forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(onTrackBuy:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];

        sheet = [[Theme theme] stylesheetForKey:@"Wall.Tracks.TrackInteractionButtonLike" error:nil];
        btn = [sheet makeButton];
        [btn addTarget:self action:@selector(onTrackLike:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        


        
//        sheet = [[Theme theme] stylesheetForKey:@"Wall.Tracks.TrackInteractionButtonAdd" error:nil];
//        btn = [sheet makeButton];
//        [btn addTarget:self action:@selector(onTrackAdd:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:btn];

        sheet = [[Theme theme] stylesheetForKey:@"Wall.Tracks.TrackInteractionButtonShare" error:nil];
        self.shareButton = [sheet makeButton];
        // deprecated. the parent view controller is in charge of the event now.
        //[self.shareButton addTarget:self action:@selector(onTrackShare:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.shareButton];

        
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
  
  if (_buttonLikedClickedTarget && _buttonLikedClickedAction)
    [_buttonLikedClickedTarget performSelector:_buttonLikedClickedAction];
}

- (void)onTrackDislike:(id)sender
{
    [[YasoundDataProvider main] setMood:eMoodDislike forSong:_song];
    [[ActivityModelessSpinner main] addRefForTimeInterval:SPINNER_DELAY];
}

- (void)onTrackAdd:(id)sender
{
    [[YasoundDataProvider main] addSongToUserRadio:_song];
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





@end

