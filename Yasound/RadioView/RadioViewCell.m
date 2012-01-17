//
//  RadioViewCell.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioViewCell.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "WallMessage.h"
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



#define MESSAGE_SPACING 4

- initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier message:(WallMessage*)m indexPath:(NSIndexPath*)indexPath
{
    self = [super initWithFrame:frame reuseIdentifier:CellIdentifier];
    if (self) 
    {
        BundleStylesheet* sheet = nil;
        self.background = self.contentView;
        UIView* view = self.background;
        
//        // background color
//        if (indexPath.row & 1)
//            sheet = [[Theme theme] stylesheetForKey:@"CellBackground1" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//        else
//            sheet = [[Theme theme] stylesheetForKey:@"CellBackground0" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//        view.backgroundColor = sheet.color;
        
        view.backgroundColor = [UIColor clearColor];
        
        // avatar
        sheet = [[Theme theme] stylesheetForKey:@"CellAvatar" error:nil];
        self.avatar = [[WebImageView alloc] initWithImageAtURL:m.avatarURL];
        self.avatar.frame = sheet.frame;
        [view addSubview:self.avatar];

        // avatar mask
        sheet = [[Theme theme] stylesheetForKey:@"CellAvatarMask" error:nil];
        UIImageView* imageView = [[[UIImageView alloc] initWithImage:[sheet image]] autorelease];
        imageView.frame = sheet.frame;
        [view addSubview:imageView];
        
        // date
        sheet = [[Theme theme] stylesheetForKey:@"CellDate" error:nil];
        self.date = [sheet makeLabel];
        self.date.text = [self dateToString:m.date];
        [view addSubview:self.date];
        
        // user
        sheet = [[Theme theme] stylesheetForKey:@"CellUser" error:nil];
        self.user = [sheet makeLabel];
        self.user.text = m.user;
        [view addSubview:self.user];

        // message background
        BundleStylesheet* messageSheet = [[Theme theme] stylesheetForKey:@"CellMessage" error:nil];
        UIView* bkg = [[UIView alloc] initWithFrame:messageSheet.frame];
        bkg.frame = CGRectMake(messageSheet.frame.origin.x, messageSheet.frame.origin.y, messageSheet.frame.size.width, m.textHeight + 2*MESSAGE_SPACING);
        
        bkg.layer.masksToBounds = YES;
        bkg.layer.cornerRadius = 4;
        bkg.layer.borderColor = [UIColor colorWithRed:231.f/255.f green:231.f/255.f blue:231.f/255.f alpha:1].CGColor;
        bkg.layer.borderWidth = 1.0; 
        bkg.layer.backgroundColor = [UIColor whiteColor].CGColor;
        [view addSubview:bkg];

        
        // message
        self.message = [messageSheet makeLabel];
        self.message.text = m.text;
        self.message.frame = CGRectMake(self.message.frame.origin.x + MESSAGE_SPACING, self.message.frame.origin.y + MESSAGE_SPACING, self.message.frame.size.width - 2*MESSAGE_SPACING, m.textHeight);
        
        [self.message setLineBreakMode:UILineBreakModeWordWrap];
        //[label setMinimumFontSize:FONT_SIZE];
        [self.message setNumberOfLines:0];        
        [view addSubview:self.message];
        
//        [self.contentView addSubview:self.background];
        
        sheet = [[Theme theme] stylesheetForKey:@"CellSeparator" error:nil];
        imageView = [[UIImageView alloc] initWithImage:[sheet image]];
        imageView.frame = CGRectMake(0, bkg.frame.origin.y + bkg.frame.size.height + sheet.frame.origin.y, sheet.frame.size.width, sheet.frame.size.height);
        [view addSubview:imageView];
        

    }
    return self;
}


- update:(WallMessage*)m indexPath:(NSIndexPath*)indexPath
{
    BundleStylesheet* sheet = nil;

    // background color
//    if (indexPath.row & 1)
//        sheet = [[Theme theme] stylesheetForKey:@"CellBackground1" error:nil];
//    else
//        sheet = [[Theme theme] stylesheetForKey:@"CellBackground0" error:nil];
//    self.background.backgroundColor = sheet.color;
    self.backgroundColor = [UIColor clearColor];
    
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




