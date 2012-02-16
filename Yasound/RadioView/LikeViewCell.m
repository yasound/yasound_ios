//
//  LikeViewCell.m
//  Yasound
//
//  Created by matthieu campion on 2/16/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "LikeViewCell.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "WallEvent.h"

@implementation LikeViewCell

@synthesize date;
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



- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier event:(WallEvent*)ev height:(CGFloat)height indexPath:(NSIndexPath*)indexPath
{
  self = [super initWithFrame:frame reuseIdentifier:CellIdentifier];
  if (self) 
  {    
    BundleStylesheet* sheet = nil;
    
    UIView* view = self.contentView;

      
      sheet = [[Theme theme] stylesheetForKey:@"MessageCellBackground" retainStylesheet:YES overwriteStylesheet:NO error:nil];
      view.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];

//      view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.12];
//      view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.12];
//    view.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
    
//    sheet = [[Theme theme] stylesheetForKey:@"LikeCellBackground" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    UIImageView* imageView = [[UIImageView alloc] initWithImage:[sheet image]];
//    imageView.frame = sheet.frame;
//    [view addSubview:imageView];
    
    sheet = [[Theme theme] stylesheetForKey:@"LikeCellPicto" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    [view addSubview:[sheet makeImage]];

    
//    sheet = [[Theme theme] stylesheetForKey:@"LikeCellDate" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    self.date = [sheet makeLabel];
//    self.date.text = [self dateToString:ev.start_date];
//    [view addSubview:self.date];
    
    sheet = [[Theme theme] stylesheetForKey:@"LikeCellMessage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.message = [sheet makeLabel];
//    self.message.text = [NSString stringWithFormat:@"%@ %@", ev.user_name, NSLocalizedString(@"User_Likes_Song_Label", nil)];
    self.message.text = [NSString stringWithFormat:@"%@", ev.user_name];
    [view addSubview:self.message];
    
    sheet = [[Theme theme] stylesheetForKey:@"CellSeparator" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[sheet image]];
    imageView.frame = CGRectMake(0, height - 2, sheet.frame.size.width, sheet.frame.size.height);
    [view addSubview:imageView];
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







