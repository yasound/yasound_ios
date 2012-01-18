//
//  SongViewCell.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "SongViewCell.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "WallEvent.h"
//#import <QuartzCore/QuartzCore.h>


@implementation SongViewCell

//@synthesize background;
//@synthesize avatar;
@synthesize date;
//@synthesize user;
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

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier event:(WallEvent*)ev height:(CGFloat)height indexPath:(NSIndexPath*)indexPath
{
    self = [super initWithFrame:frame reuseIdentifier:CellIdentifier];
    if (self) 
    {
//        //LBDEBUG ICI
//        if (height == 0)
//            return self;
        
        BundleStylesheet* sheet = nil;
        
        UIView* view = self.contentView;
        
        sheet = [[Theme theme] stylesheetForKey:@"SongCellBackground" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIImageView* imageView = [[UIImageView alloc] initWithImage:[sheet image]];
        imageView.frame = sheet.frame;
        [view addSubview:imageView];
        
        sheet = [[Theme theme] stylesheetForKey:@"SongCellDate" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.date = [sheet makeLabel];
        self.date.text = [self dateToString:ev.start_date];
        [view addSubview:self.date];

        sheet = [[Theme theme] stylesheetForKey:@"SongCellMessage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.message = [sheet makeLabel];
        self.message.text = ev.song.metadata.name;
        [view addSubview:self.message];

        
        
//        self.background = self.contentView;
//        UIView* view = self.background;
        
//        // background color
//        if (indexPath.row & 1)
//            sheet = [[Theme theme] stylesheetForKey:@"CellBackground1" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//        else
//            sheet = [[Theme theme] stylesheetForKey:@"CellBackground0" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//        view.backgroundColor = sheet.color;
        
//        view.backgroundColor = [UIColor clearColor];
        
        
//        sheet = [[Theme theme] stylesheetForKey:@"CellSeparator" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//        imageView = [[UIImageView alloc] initWithImage:[sheet image]];
//        imageView.frame = CGRectMake(0, bkg.frame.origin.y + bkg.frame.size.height + sheet.frame.origin.y, sheet.frame.size.width, sheet.frame.size.height);
//        [view addSubview:imageView];
        

    }
    return self;
}


- (void)update:(WallEvent*)ev height:(CGFloat)height indexPath:(NSIndexPath*)indexPath
{
    BundleStylesheet* sheet = nil;
    
//    //LBDEBUG ICI
//    if (height == 0)
//        return;

    // background color
//    if (indexPath.row & 1)
//        sheet = [[Theme theme] stylesheetForKey:@"CellBackground1" error:nil];
//    else
//        sheet = [[Theme theme] stylesheetForKey:@"CellBackground0" error:nil];
//    self.background.backgroundColor = sheet.color;
//    self.backgroundColor = [UIColor clearColor];
    
    // avatar
//    [self.avatar setImage:image];
    
    // date
//    self.date.text = [self dateToString:m.date];
    self.date.text = [self dateToString:ev.start_date];
    
    // user
//    self.user.text = m.user;
//    self.user.text = ev.user.name;
    
    // message
//    self.message.text = m.te;
//    self.message.frame = CGRectMake(self.message.frame.origin.x, self.message.frame.origin.y, self.message.frame.size.width, m.textHeight);

    self.message.text = ev.song.metadata.name;
//    self.message.frame = CGRectMake(self.message.frame.origin.x, self.message.frame.origin.y, self.message.frame.size.width, height);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
	[super setSelected:selected animated:animated];
    
	// Configure the view for the selected state
}

@end




