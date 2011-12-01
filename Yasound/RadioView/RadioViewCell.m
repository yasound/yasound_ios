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


- initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier message:(Message*)m indexPath:(NSIndexPath*)indexPath
{
    self = [super initWithFrame:frame reuseIdentifier:CellIdentifier];
    if (self) 
    {
        BundleStylesheet* sheet = nil;
        self.background = [[UIView alloc] initWithFrame:self.frame];
        UIView* view = self.background;
        
        
        // background color
        if (indexPath.row & 1)
            sheet = [[Theme theme] stylesheetForKey:@"RadioViewCellBackground1" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        else
            sheet = [[Theme theme] stylesheetForKey:@"RadioViewCellBackground0" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        view.backgroundColor = sheet.color;
        
        // avatar
        sheet = [[Theme theme] stylesheetForKey:@"RadioViewCellAvatar" error:nil];
        self.avatar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatarDummy2.png"]];
        self.avatar.frame = sheet.frame;
        [self.avatar.layer setBorderColor: [sheet.color CGColor]];
        [self.avatar.layer setBorderWidth: [[sheet.customProperties objectForKey:@"borderSize"] integerValue]];    
        [view addSubview:self.avatar];
        
        // date
        sheet = [[Theme theme] stylesheetForKey:@"RadioViewCellDate" error:nil];
        self.date = [sheet makeLabel];
        self.date.text = m.date;
        [view addSubview:self.date];
        
        // user
        sheet = [[Theme theme] stylesheetForKey:@"RadioViewCellUser" error:nil];
        self.user = [sheet makeLabel];
        self.user.text = m.user;
        [view addSubview:self.user];
        
        // message
        sheet = [[Theme theme] stylesheetForKey:@"RadioViewCellMessage" error:nil];
        self.message = [sheet makeLabel];
        self.message.text = m.message;
        [view addSubview:self.message];
        

        [self.contentView addSubview:self.background];

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
    self.date.text = m.date;
    
    // user
    self.user.text = m.user;
    
    // message
    self.message.text = m.message;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
	[super setSelected:selected animated:animated];
    
	// Configure the view for the selected state
}


@end




