//
//  NotificationViewCell.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "NotificationViewCell.h"
#import "NotificationManager.h"

@implementation NotificationViewCell

@synthesize notifIdentifier;
@synthesize notifSwitch;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier notifIdentifier:(NSString*)notifIdentifier
{
    self = [super initWithFrame:frame reuseIdentifier:CellIdentifier];
    if (self) 
    {
        self.notifIdentifier = notifIdentifier;
        
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.text = NSLocalizedString(self.notifIdentifier, nil);
        
        self.notifSwitch = [[UISwitch alloc] init];
        CGRect frame = self.notifSwitch.frame;
        self.notifSwitch.frame = CGRectMake(self.frame.size.width - frame.size.width - 8, (self.frame.size.height - frame.size.height) / 2.f, frame.size.width, frame.size.height);
        [self addSubview:self.notifSwitch];
        
        [self.notifSwitch addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
        
        self.notifSwitch.on = [[[NotificationManager main].notifications objectForKey:notifIdentifier] boolValue];

    }
    return self;
}


- (void)update:(NSString*)notifIdentifier
{
    self.notifIdentifier = notifIdentifier;
    self.textLabel.text = NSLocalizedString(self.notifIdentifier, nil);
    self.notifSwitch.on = [[[NotificationManager main].notifications objectForKey:notifIdentifier] boolValue];
}



- (void)onSwitch:(id)sender
{
    [[NotificationManager main].notifications setObject:[NSNumber numberWithBool:self.notifSwitch.on] forKey:self.notifIdentifier];
    [[NotificationManager main] save];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
    
	[super setSelected:selected animated:animated];
    
	// Configure the view for the selected state
}

@end




