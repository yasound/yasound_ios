//
//  NotificationViewCell.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "NotificationViewCell.h"
#import "NotificationManager.h"
#import "BundleFileManager.h"

@implementation NotificationViewCell

@synthesize notifIdentifier;
@synthesize label;
@synthesize notifSwitch;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier notifIdentifier:(NSString*)notifIdentifier
{
    self = [super initWithFrame:frame reuseIdentifier:CellIdentifier];
    if (self) 
    {
        self.notifIdentifier = notifIdentifier;
        
        BundleStylesheet* sheet = [[BundleFileManager main] stylesheetForKey:@"NotificationViewCellLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.label = [sheet makeLabel];
        self.label.adjustsFontSizeToFitWidth = YES;
        self.label.minimumFontSize = 10;
        self.label.text = NSLocalizedString(self.notifIdentifier, nil);
        [self addSubview:self.label];
        
        self.notifSwitch = [[UISwitch alloc] init];
        CGRect frame = self.notifSwitch.frame;
        self.notifSwitch.frame = CGRectMake(self.frame.size.width - frame.size.width - 16, (self.frame.size.height - frame.size.height) / 2.f, frame.size.width, frame.size.height);
        [self addSubview:self.notifSwitch];
        
        [self.notifSwitch addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
        
        self.notifSwitch.on = [[NotificationManager main] get:notifIdentifier];

    }
    return self;
}


- (void)update:(NSString*)notifIdentifier
{
    self.notifIdentifier = notifIdentifier;
    self.label.text = NSLocalizedString(self.notifIdentifier, nil);
    self.notifSwitch.on = [[NotificationManager main] get:notifIdentifier];
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




