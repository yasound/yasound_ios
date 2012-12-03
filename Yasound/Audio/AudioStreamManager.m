//
//  AudioStreamManager.m
//  yasound
//
//  Created by LOIC BERTHELOT on 01/2012
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioStreamManager.h"
#import "AudioStreamer.h"
#import "YasoundDataProvider.h"
#import "YasoundSessionManager.h"

//#define USE_FAKE_RADIO_URL 1

@implementation AudioStreamManager

@synthesize currentRadio;
@synthesize isPaused = _isPaused;



#ifdef USE_DEV_SERVER
#define ASLog( s, ... )
#else
#define ASLog( s, ... ) DLog( @"%@", [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#endif



static AudioStreamManager* _main = nil;

static AudioStreamer* _gAudioStreamer = nil;


+ (AudioStreamManager*) main
{
    if (_main == nil)
    {
        _main = [[AudioStreamManager alloc] init];
    }
    
    return _main;
}




- (id)init
{
    if (self = [super init])
    {
        self.currentRadio = nil;
        _isPaused = NO;
        _reseting = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioStreamNotif:) name:NOTIF_AUDIOSTREAM_ERROR object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioStreamMyReset:) name:NOTIF_AUDIOSTREAM_RESET object:nil];
    }
    
    return self;
}


- (void)startRadio:(Radio*)radio
{
    if (radio == nil)
        return;

    if ((_streamErrorTimer != nil) && [_streamErrorTimer isValid])
    {
        [_streamErrorTimer invalidate];
        _streamErrorTimer = nil;
    }
    
    [self _startRadio:radio];
}


- (void)_startRadio:(Radio*)radio
{
#if MUTE_RADIO
    return;
#endif
    
//#ifdef USE_DEV_SERVER
//    return;
//#endif
    
    if (radio == nil)
        return;

    if (!_reseting && (_gAudioStreamer && ([radio.id intValue]  == [self.currentRadio.id intValue])))
        return;
    
    _isPaused = NO;
    _reseting = NO;
    
    if (_gAudioStreamer != nil)
    {
        [_gAudioStreamer stop];
        [_gAudioStreamer release];
        _gAudioStreamer = nil;
    }

    self.currentRadio = radio;
    
    // save the current radio reference in the user defaults
    // to retrieve it when the app starts
    [[UserSettings main] setObject:self.currentRadio.id forKey:USKEYnowPlaying];

    NSString* url = radio.stream_url;    
    NSURL* radiourl = [NSURL URLWithString:url];
  
    if ([YasoundSessionManager main].registered)
    {
        [[YasoundDataProvider main] streamingAuthenticationTokenWithCompletionBlock:^(int status, NSString* response, NSError* error){
            if (error)
            {
                DLog(@"streaming auth token error: %d - %@", error.code, error. domain);
                return;
            }
            if (status != 200)
            {
                DLog(@"streaming auth token error: response status %d", status);
                return;
            }
            NSDictionary* dict = [response jsonToDictionary];
            if (dict == nil)
            {
                DLog(@"streaming auth token error: cannot parse response %@", response);
                return;
            }
            NSString* token = [dict valueForKey:@"token"];
            if (token == nil)
            {
                DLog(@"streaming auth token error: bad response %@", response);
                return;
            }
            
            NSString* paramStr = radiourl.parameterString;
            NSString* urlStr = radiourl.absoluteString;
            NSString* finalUrlStr = urlStr;
            
            NSLog(@"radio origin '%@'", self.currentRadio.origin);
            
            if ([self.currentRadio.origin integerValue] == eRadioOriginYasound)
            {    
                if (paramStr)
                {
                    finalUrlStr = [finalUrlStr stringByAppendingFormat:@"&token=%@", token];
                }
                else
                {
                    finalUrlStr = [finalUrlStr stringByAppendingFormat:@"/?token=%@", token];
                }
                
                BOOL hdPermission = [[YasoundDataProvider main].user permission:PERM_HD];
                BOOL hdRequest = [[UserSettings main] boolForKey:USKEYuserWantsHd error:nil];
                
                if (hdPermission && hdRequest)
                {
                    finalUrlStr = [finalUrlStr stringByAppendingString:@"&hd=1"];
                }
            }
            NSURL* finalRadioUrl = [NSURL URLWithString:finalUrlStr];
            DLog(@"radio authenticated url: %@\n", finalRadioUrl);
            [self startStreamerWithURL:finalRadioUrl];
        }];
    }
    else
    {
        DLog(@"radio url: %@\n", radiourl);
        [self startStreamerWithURL:radiourl];
    }
}

- (void)startStreamerWithURL:(NSURL*)radioUrl
{
    NSString* cookie = [NSString stringWithFormat:@"username=%@; api_key=%@", [YasoundDataProvider username], [YasoundDataProvider user_apikey]];
    _gAudioStreamer = [[AudioStreamer alloc] initWithURL:radioUrl andCookie:cookie];
    [_gAudioStreamer start];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUDIOSTREAM_PLAY object:nil];
}

- (void)stopRadio
{
    if ((_streamErrorTimer != nil) && [_streamErrorTimer isValid])
    {
        [_streamErrorTimer invalidate];
        _streamErrorTimer = nil;
    }
    
    [self _stopRadioWithNotification:YES];
}


- (void)_stopRadioWithNotification:(BOOL)withNotif
{
#if MUTE_RADIO
    return;
#endif
    
    if (_gAudioStreamer == nil)
        return;

    _isPaused = YES;
    
    [_gAudioStreamer stop];
    [_gAudioStreamer release];
    _gAudioStreamer = nil;
    
    if (withNotif)
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUDIOSTREAM_STOP object:nil];

}



- (void)pauseRadio
{
    if (_gAudioStreamer == nil)
        return;
    
    _isPaused = YES;

    [_gAudioStreamer stop];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUDIOSTREAM_STOP object:nil];
}



- (void)playRadio
{
#if MUTE_RADIO
    return;
#endif
    
    if (_gAudioStreamer == nil)
        return;

    _isPaused = NO;
    [_gAudioStreamer start];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUDIOSTREAM_PLAY object:nil];
}

- (void)togglePlayPauseRadio
{
  if (_gAudioStreamer == nil)
      [self startRadio:self.currentRadio];
       
  else
  
  if (_gAudioStreamer.state != AS_PLAYING)
      [self playRadio];
  else
    [self pauseRadio];
}


#pragma mark - AVAudioSession Delegate

- (void)beginInterruption
{
  [self stopRadio];
}

- (void) endInterruptionWithFlags: (NSUInteger) flags
{
  if (flags & AVAudioSessionInterruptionFlags_ShouldResume)
  {
    [self playAudio];    
  }
}











#define STREAM_ERROR_TIMER_PERIOD 5

- (void)onAudioStreamNotif:(NSNotification*)notif
{
    
    if ((_streamErrorTimer != nil) && [_streamErrorTimer isValid])
        return;

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DISPLAY_AUDIOSTREAM_ERROR object:nil];

    
    _streamErrorCount++;

    _streamErrorTimer = [NSTimer scheduledTimerWithTimeInterval:STREAM_ERROR_TIMER_PERIOD target:self selector:@selector(onStreamErrorHandling:) userInfo:nil repeats:NO];
    
}



- (void)onAudioStreamMyReset:(NSNotification*)notif
{
    DLog(@"onAudioStreamMyReset");
    
    Radio* radio = self.currentRadio;
    if (radio == nil)
        return;
    
    _reseting = YES;
    
    [self _startRadio:radio];
}






- (void)onStreamErrorHandling:(NSTimer*)timer
{
    [[AudioStreamManager main] _stopRadioWithNotification:NO];
    [[AudioStreamManager main] _startRadio:self.currentRadio];
    
    _streamErrorTimer = nil;
}



@end