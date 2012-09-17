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
//@synthesize label;
@synthesize notifSwitch;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier notifIdentifier:(NSString*)identifier
{
    self = [super initWithFrame:frame reuseIdentifier:CellIdentifier];
    if (self) 
    {
        self.notifIdentifier = identifier;
        
//        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Notifications.label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//        self.label = [sheet makeLabel];
//        self.label.adjustsFontSizeToFitWidth = YES;
//        self.label.minimumFontSize = 10;
//        self.label.text = NSLocalizedString(self.notifIdentifier, nil);
//        [self addSubview:self.label];
        
        self.textLabel.text = NSLocalizedString(self.notifIdentifier, nil);
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        
        self.notifSwitch = [[UISwitch alloc] init];
        self.accessoryView = self.notifSwitch;
//        [self update:self.notifIdentifier];
        [self.notifSwitch addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
        self.notifSwitch.on = [[NotificationManager main] get:identifier];

        //        CGRect frame = self.notifSwitch.frame;
//        self.notifSwitch.frame = CGRectMake(self.frame.size.width - frame.size.width - 16, (self.frame.size.height - frame.size.height) / 2.f, frame.size.width, frame.size.height+10);
//        [self addSubview:self.notifSwitch];
//        
//

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
//    [[NotificationManager main] save];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
    
	[super setSelected:selected animated:animated];
    
	// Configure the view for the selected state
}

@end




