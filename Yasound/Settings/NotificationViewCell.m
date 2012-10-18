//
//  NotificationViewCell.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "NotificationViewCell.h"
#import "NotificationManager.h"
#import "Theme.h"

@implementation NotificationViewCell

@synthesize notifIdentifier;
@synthesize notifSwitch;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier notifIdentifier:(NSString*)identifier
{
    self = [super initWithFrame:frame reuseIdentifier:CellIdentifier];
    if (self) 
    {
        self.notifIdentifier = identifier;
        
        self.textLabel.text = NSLocalizedString(self.notifIdentifier, nil);
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        
        self.notifSwitch = [[UISwitch alloc] init];
        self.accessoryView = self.notifSwitch;
        [self.notifSwitch addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
        self.notifSwitch.on = [[NotificationManager main] get:identifier];

    }
    return self;
}


- (void)update:(NSString*)identifier
{
    self.notifIdentifier = identifier;
    self.textLabel.text = NSLocalizedString(self.notifIdentifier, nil);
    BOOL value = [[NotificationManager main] get:identifier];
    
    self.notifSwitch.on = value;
}



- (void)onSwitch:(id)sender
{
    [[NotificationManager main].notifications setObject:[NSNumber numberWithBool:self.notifSwitch.on] forKey:self.notifIdentifier];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
    
	[super setSelected:selected animated:animated];
    
	// Configure the view for the selected state
}

@end




