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
#import "YasoundDataProvider.h"

#import <QuartzCore/QuartzCore.h>

@implementation RadioViewCell

//@synthesize background;
@synthesize avatar;
@synthesize avatarMask;
@synthesize date;
@synthesize user;
@synthesize message;
@synthesize messageBackground;
@synthesize separator;

- (NSString*) dateToString:(NSDate*)d
{
  NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:@"dd/MM' 'HH:mm"];
  NSString* s = [dateFormat stringFromDate:d];
  [dateFormat release];
  return s;
}



#define MESSAGE_SPACING 4

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier event:(WallEvent*)ev indexPath:(NSIndexPath*)indexPath target:(id)target action:(SEL)action
{
    self = [super initWithFrame:frame reuseIdentifier:CellIdentifier];
    if (self) 
    {
        _myTarget = target;
        _myAction = action;
        
        BundleStylesheet* sheet = nil;
//        self.background = self.contentView;
//        UIView* view = self.background;
        UIView* view = self.contentView;
        
        
        sheet = [[Theme theme] stylesheetForKey:@"CellMessage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIFont* messageFont = [sheet makeFont];
        CGFloat messageWidth = sheet.frame.size.width;

        
        assert([ev isTextHeightComputed] == YES);
        CGFloat height = [ev getTextHeight];
        
        
//        view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.12];
        
        sheet = [[Theme theme] stylesheetForKey:@"MessageCellBackground" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        view.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
        
        // avatar
        sheet = [[Theme theme] stylesheetForKey:@"CellAvatar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.avatar = [[WebImageView alloc] initWithImageAtURL:[[YasoundDataProvider main] urlForPicture:ev.user_picture]];
        self.avatar.frame = sheet.frame;
        [view addSubview:self.avatar];
        
        // set target from parent
        self.avatarMask = [[InteractiveView alloc] initWithFrame:sheet.frame target:self action:@selector(onAvatarClicked:)];
        [view addSubview:self.avatarMask];
        
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
        self.messageBackground = [[UIView alloc] initWithFrame:messageSheet.frame];
        self.messageBackground.frame = CGRectMake(messageSheet.frame.origin.x, messageSheet.frame.origin.y, messageSheet.frame.size.width, height + 2*MESSAGE_SPACING);
        
        self.messageBackground.layer.masksToBounds = YES;
        self.messageBackground.layer.cornerRadius = 4;
        self.messageBackground.layer.borderColor = [UIColor colorWithRed:231.f/255.f green:231.f/255.f blue:231.f/255.f alpha:1].CGColor;
        self.messageBackground.layer.borderWidth = 1.0; 
        self.messageBackground.layer.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1].CGColor;
        [view addSubview:self.messageBackground];

        
        // message
        self.message = [messageSheet makeLabel];
        self.message.text = ev.text;
        self.message.frame = CGRectMake(self.message.frame.origin.x + MESSAGE_SPACING, self.message.frame.origin.y + MESSAGE_SPACING, self.message.frame.size.width - 2*MESSAGE_SPACING, height);
        
        [self.message setLineBreakMode:UILineBreakModeWordWrap];
        [self.message setNumberOfLines:0];        
        [view addSubview:self.message];
        
        sheet = [[Theme theme] stylesheetForKey:@"CellSeparator" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.separator = [[UIImageView alloc] initWithImage:[sheet image]];
        self.separator.frame = CGRectMake(0, height + THE_REST_OF_THE_CELL_HEIGHT - sheet.frame.size.height, sheet.frame.size.width, sheet.frame.size.height);
        [view addSubview:self.separator];
        

    }
    return self;
}


- (void)update:(WallEvent*)ev indexPath:(NSIndexPath*)indexPath
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


- (void)onAvatarClicked:(id)sender
{
    if (_myTarget == nil)
        return;
    
    [_myTarget performSelector:_myAction withObject:self];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
    
	[super setSelected:selected animated:animated];
    
	// Configure the view for the selected state
}



- (void)willMoveToSuperview:(UIView *)newSuperview 
{
    [super willMoveToSuperview:newSuperview];
    if(!newSuperview) 
    {
        [self.avatar releaseCache];
    }
}


@end




