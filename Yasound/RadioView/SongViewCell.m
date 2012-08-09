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
//  [dateFormat setDateFormat:@"HH:mm"];
  NSDate* now = [NSDate date];
  NSDateComponents* todayComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:now];
  NSDateComponents* refComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:d];
  
  if (todayComponents.year == refComponents.year && todayComponents.month == refComponents.month && todayComponents.day == refComponents.day)
  {
    // today: show time
    [dateFormat setDateFormat:@"HH:mm"];
  }
  else
  {
    // not today: show date
    [dateFormat setDateFormat:@"dd/MM"];
  }
  
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
        BundleStylesheet* sheet = nil;
        
        UIView* view = self.contentView;
        
        sheet = [[Theme theme] stylesheetForKey:@"Wall.cellSong.background" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIImageView* imageView = [[UIImageView alloc] initWithImage:[sheet image]];
        imageView.frame = sheet.frame;
        [view addSubview:imageView];
        
        sheet = [[Theme theme] stylesheetForKey:@"Wall.cellSong.date" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.date = [sheet makeLabel];
        self.date.text = [self dateToString:ev.start_date];
        [view addSubview:self.date];

        sheet = [[Theme theme] stylesheetForKey:@"Wall.cellSong.message" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.message = [sheet makeLabel];
        self.message.text = [NSString stringWithFormat:@"%@ - %@", ev.song_artist, ev.song_name];
        [view addSubview:self.message];

    }
    return self;
}


- (void)update:(WallEvent*)ev height:(CGFloat)height indexPath:(NSIndexPath*)indexPath
{
    BundleStylesheet* sheet = nil;
    
    self.date.text = [self dateToString:ev.start_date];
    self.message.text = ev.song_name;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
	[super setSelected:selected animated:animated];
    
	// Configure the view for the selected state
}

@end




