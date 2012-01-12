//
//  QualitySwitchLabel.m
//
//  Created by Loïc Berthelot on 01/11/12.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "QualitySwitchLabel.h"
#import "ActivityAlertView.h"

@implementation QualitySwitchLabel

@synthesize label;


- (void)loadView
{
    self.backgroundColor = [UIColor clearColor];
    
    self.label = [[UILabel alloc] initWithFrame:self.frame];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.textColor = [UIColor whiteColor];
    self.label.font = [UIFont fontWithName:@"Arial" size:10];
    
    [self addSubview:self.label];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL highQuality = NO;
    NSNumber* nb = [defaults objectForKey:USERDEFAULTS_SOUNDQUALITY_KEY];
    if (nb != nil)
        highQuality = [nb boolValue];
    
    if (highQuality)
        self.label.text = NSLocalizedString(@"QualitySwitch_high_quality_label", nil);
    else
        self.label.text = NSLocalizedString(@"QualitySwitch_standard_quality_label", nil);
    
}




#pragma mark - touches actions




- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    UITouch *aTouch = [touches anyObject];
    
//    if (aTouch.tapCount == 2) 
    
}




//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
//{
//    
//}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    UITouch *theTouch = [touches anyObject];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL highQuality = [[defaults objectForKey:@"HighSoundQuality"] boolValue];
    
    if (highQuality)
    {
        self.label.text = NSLocalizedString(@"QualitySwitch_standard_quality_label", nil);
        [defaults setObject:[NSNumber numberWithBool:NO] forKey:USERDEFAULTS_SOUNDQUALITY_KEY];
        [ActivityAlertView showWithTitle:NSLocalizedString(@"QualitySwitch_standard_quality_switch", nil) closeAfterTimeInterval:ACTIVITYALERT_TIMEINTERVAL];
    }
    else
    {
        self.label.text = NSLocalizedString(@"QualitySwitch_high_quality_label", nil);
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:USERDEFAULTS_SOUNDQUALITY_KEY];
        [ActivityAlertView showWithTitle:NSLocalizedString(@"QualitySwitch_high_quality_switch", nil) closeAfterTimeInterval:ACTIVITYALERT_TIMEINTERVAL];    
    }
    
    [defaults synchronize];
    
}

@end
