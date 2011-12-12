//
//  RadioViewCell.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioViewCell.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "Message.h"
#import <QuartzCore/QuartzCore.h>


@implementation RadioViewCell

@synthesize background;
@synthesize avatar;
@synthesize date;
@synthesize user;
@synthesize message;

- (NSString*) dateToString:(NSDate*)d
{
  NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:@"dd--MM--yyyy' 'HH:mm"];
  NSString* s = [dateFormat stringFromDate:d];
  [dateFormat release];
  return s;
}


- initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier message:(Message*)m indexPath:(NSIndexPath*)indexPath
{
    self = [super initWithFrame:frame reuseIdentifier:CellIdentifier];
    if (self) 
    {
        BundleStylesheet* sheet = nil;
        self.background = self.contentView;
        UIView* view = self.background;
        
        // background color
        if (indexPath.row & 1)
            sheet = [[Theme theme] stylesheetForKey:@"RadioViewCellBackground1" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        else
            sheet = [[Theme theme] stylesheetForKey:@"RadioViewCellBackground0" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        view.backgroundColor = sheet.color;
        
        // avatar
        sheet = [[Theme theme] stylesheetForKey:@"RadioViewCellAvatar" error:nil];
        NSURL* url = [NSURL URLWithString:m.avatarURL];
        self.avatar = [[WebImageView alloc] initWithImageAtURL:url];
        self.avatar.frame = sheet.frame;
        [self.avatar.layer setBorderColor: [sheet.color CGColor]];
        [self.avatar.layer setBorderWidth: [[sheet.customProperties objectForKey:@"borderSize"] integerValue]];    
        [view addSubview:self.avatar];
        
        // date
        sheet = [[Theme theme] stylesheetForKey:@"RadioViewCellDate" error:nil];
        self.date = [sheet makeLabel];
        self.date.text = [self dateToString:m.date];
        [view addSubview:self.date];
        
        // user
        sheet = [[Theme theme] stylesheetForKey:@"RadioViewCellUser" error:nil];
        self.user = [sheet makeLabel];
        self.user.text = m.user;
        [view addSubview:self.user];
        
        // message
        sheet = [[Theme theme] stylesheetForKey:@"RadioViewCellMessage" error:nil];
        self.message = [sheet makeLabel];
        self.message.text = m.text;
        self.message.frame = CGRectMake(self.message.frame.origin.x, self.message.frame.origin.y, self.message.frame.size.width, m.textHeight);
        [self.message setLineBreakMode:UILineBreakModeWordWrap];
        //[label setMinimumFontSize:FONT_SIZE];
        [self.message setNumberOfLines:0];        
        [view addSubview:self.message];
        

//        [self.contentView addSubview:self.background];

    }
    return self;
}


- update:(Message*)m indexPath:(NSIndexPath*)indexPath
{
    BundleStylesheet* sheet = nil;

    // background color
    if (indexPath.row & 1)
        sheet = [[Theme theme] stylesheetForKey:@"RadioViewCellBackground1" error:nil];
    else
        sheet = [[Theme theme] stylesheetForKey:@"RadioViewCellBackground0" error:nil];
    self.background.backgroundColor = sheet.color;
    
    // avatar
//    [self.avatar setImage:image];
    
    // date
  self.date.text = [self dateToString:m.date];
    
    // user
    self.user.text = m.user;
    
    // message
    self.message.text = m.text;
    self.message.frame = CGRectMake(self.message.frame.origin.x, self.message.frame.origin.y, self.message.frame.size.width, m.textHeight);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
	[super setSelected:selected animated:animated];
    
	// Configure the view for the selected state
}

@end




