//
//  NotificationViewCell.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "NotificationViewCell.h"

@implementation NotificationViewCell

@synthesize notifSwitch;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier notifIdentifier:(NSString*)notifIdentifier
{
    self = [super initWithFrame:frame reuseIdentifier:CellIdentifier];
    if (self) 
    {
        self.notifIdentifier = notifIdentifier;
        
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.text = NSLocalizedString(self.notifIdentifier, nil);
        
        _switchEnabled = [[UISwitch alloc] init];
        _switchEnabled.frame = CGRectMake(sheet.frame.origin.x, sheet.frame.origin.y, _switchEnabled.frame.size.width, _switchEnabled.frame.size.height);


    }
    return self;
}


- (void)update:(NSString*)notifIdentifier
{
    assert([ev isTextHeightComputed] == YES);
    CGFloat height = [ev getTextHeight];
    
    self.date.text = [self dateToString:ev.start_date];
    self.user.text = ev.user_name;
    self.message.text = ev.text;
    
    self.messageBackground.frame = CGRectMake(self.messageBackground.frame.origin.x, self.messageBackground.frame.origin.y, self.messageBackground.frame.size.width, height + 2*MESSAGE_SPACING);
    
    self.message.frame = CGRectMake(self.message.frame.origin.x, self.message.frame.origin.y, self.message.frame.size.width, height);
    
    self.separator.frame = CGRectMake(0, height + THE_REST_OF_THE_CELL_HEIGHT - 2, self.separator.frame.size.width, self.separator.frame.size.height);
  
  [self.avatar setUrl:[[YasoundDataProvider main] urlForPicture:ev.user_picture]];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
    
	[super setSelected:selected animated:animated];
    
	// Configure the view for the selected state
}

@end




