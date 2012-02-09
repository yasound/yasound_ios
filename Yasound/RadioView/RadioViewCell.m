//
//  RadioViewCell.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioViewCell.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "WallEvent.h"
#import <QuartzCore/QuartzCore.h>
#import "YasoundDataProvider.h"


@implementation RadioViewCell

@synthesize background;
@synthesize avatar;
@synthesize date;
@synthesize user;
@synthesize message;

- (NSString*) dateToString:(NSDate*)d
{
  NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:@"dd/MM' 'HH:mm"];
  NSString* s = [dateFormat stringFromDate:d];
  [dateFormat release];
  return s;
}



#define MESSAGE_SPACING 4

- initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier event:(WallEvent*)ev height:(CGFloat)ParamHeight indexPath:(NSIndexPath*)indexPath
{
    self = [super initWithFrame:frame reuseIdentifier:CellIdentifier];
    if (self) 
    {
        BundleStylesheet* sheet = nil;
        self.background = self.contentView;
        UIView* view = self.background;
        
        
        sheet = [[Theme theme] stylesheetForKey:@"CellMessage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIFont* messageFont = [sheet makeFont];
        CGFloat messageWidth = sheet.frame.size.width;

        
        assert([ev isTextHeightComputed] == YES);
        CGFloat height = [ev getTextHeight];
        
        
        view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.12];
        
        // avatar
        sheet = [[Theme theme] stylesheetForKey:@"CellAvatar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.avatar = [[WebImageView alloc] initWithImageAtURL:[[YasoundDataProvider main] urlForPicture:ev.user_picture]];
        self.avatar.frame = sheet.frame;
        [view addSubview:self.avatar];
        
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = 6;


        // date
        sheet = [[Theme theme] stylesheetForKey:@"CellDate" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.date = [sheet makeLabel];
        self.date.text = [self dateToString:ev.start_date];
        [view addSubview:self.date];
        
        // user
        sheet = [[Theme theme] stylesheetForKey:@"CellUser" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.user = [sheet makeLabel];
        self.user.text = ev.user_name;
        [view addSubview:self.user];

        // message background
        BundleStylesheet* messageSheet = [[Theme theme] stylesheetForKey:@"CellMessage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIView* bkg = [[UIView alloc] initWithFrame:messageSheet.frame];
        bkg.frame = CGRectMake(messageSheet.frame.origin.x, messageSheet.frame.origin.y, messageSheet.frame.size.width, height + 2*MESSAGE_SPACING);
        
        bkg.layer.masksToBounds = YES;
        bkg.layer.cornerRadius = 4;
        bkg.layer.borderColor = [UIColor colorWithRed:231.f/255.f green:231.f/255.f blue:231.f/255.f alpha:1].CGColor;
        bkg.layer.borderWidth = 1.0; 
        bkg.layer.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9].CGColor;
        [view addSubview:bkg];

        
        // message
        self.message = [messageSheet makeLabel];
        self.message.text = ev.text;
        self.message.frame = CGRectMake(self.message.frame.origin.x + MESSAGE_SPACING, self.message.frame.origin.y + MESSAGE_SPACING, self.message.frame.size.width - 2*MESSAGE_SPACING, height);
        
        [self.message setLineBreakMode:UILineBreakModeWordWrap];
        [self.message setNumberOfLines:0];        
        [view addSubview:self.message];
        
        sheet = [[Theme theme] stylesheetForKey:@"CellSeparator" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIImageView* imageView = [[UIImageView alloc] initWithImage:[sheet image]];
        imageView.frame = CGRectMake(0, height + THE_REST_OF_THE_CELL_HEIGHT - 2, sheet.frame.size.width, sheet.frame.size.height);
        [view addSubview:imageView];
        

    }
    return self;
}


- update:(WallEvent*)ev height:(CGFloat)height indexPath:(NSIndexPath*)indexPath
{
    BundleStylesheet* sheet = nil;

    self.backgroundColor = [UIColor clearColor];
    self.date.text = [self dateToString:ev.start_date];
    self.user.text = ev.user_name;
    self.message.text = ev.text;
    self.message.frame = CGRectMake(self.message.frame.origin.x, self.message.frame.origin.y, self.message.frame.size.width, height);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
    
	[super setSelected:selected animated:animated];
    
	// Configure the view for the selected state
}

@end




