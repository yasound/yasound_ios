//
//  RadioSelectionTableViewCell.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioSelectionTableViewCell.h"
#import "BundleFileManager.h"

@implementation RadioSelectionTableViewCell


@synthesize radioTitle;
@synthesize radioSubtitle1;
@synthesize radioSubtitle2;
@synthesize radioLikes;
@synthesize radioListeners;
@synthesize radioAvatar;
@synthesize radioAvatarMask;

static UIImage* gGrayMask = nil;

static NSArray* gFakeUsers = nil;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier rowIndex:(NSInteger)rowIndex
{
  if (self = [super initWithFrame:frame reuseIdentifier:cellIdentifier]) 
  {
    BundleStylesheet* stylesheet;
    NSError* error;
    
    // static init
    if (gFakeUsers == nil)
    {
      NSDictionary* resources = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Resources"];
      gFakeUsers = [resources objectForKey:@"fakeUsers"];
      srand(time(NULL));
    }
    NSInteger fakeUserIndex = rand() % 3;
    
    
    // cell background
    [self addSubview:[BundleStylesheet BSMakeImage:[[BundleFileManager main] stylesheetForKey:@"RadioSelectionBackground" error:&error]]];
  
    // avatar
    self.radioAvatar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[[gFakeUsers objectAtIndex:fakeUserIndex] valueForKey:@"image"]]];
    stylesheet = [[BundleFileManager main] stylesheetForKey:@"RadioSelectionAvatar" error:&error];
    self.radioAvatar.frame = stylesheet.frame;
    [self addSubview:self.radioAvatar];
    
    // avatar mask
    NSString* avatarMask;
    if (rowIndex & 1)
      avatarMask = @"RadioSelectionMaskGray";
    else
      avatarMask = @"RadioSelectionMaskWhite";
    stylesheet = [[BundleFileManager main] stylesheetForKey:avatarMask error:&error];
    self.radioAvatarMask = [BundleStylesheet BSMakeImage:stylesheet];
    [self addSubview:self.radioAvatarMask];
    
    // title
    self.radioTitle = [BundleStylesheet BSMakeLabel:[[BundleFileManager main] stylesheetForKey:@"RadioSelectionTitle" error:&error]];
    self.radioTitle.text = [[gFakeUsers objectAtIndex:fakeUserIndex] valueForKey:@"title"];
    [self addSubview:self.radioTitle];

    // subtitle 1
    self.radioSubtitle1 = [BundleStylesheet BSMakeLabel:[[BundleFileManager main] stylesheetForKey:@"RadioSelectionSubtitle1" error:&error]];
    self.radioSubtitle1.text = [[gFakeUsers objectAtIndex:fakeUserIndex] valueForKey:@"subtitle1"];
    [self addSubview:self.radioSubtitle1];

    // subtitle 2
    self.radioSubtitle2 = [BundleStylesheet BSMakeLabel:[[BundleFileManager main] stylesheetForKey:@"RadioSelectionSubtitle2" error:&error]];
    self.radioSubtitle2.text = [[gFakeUsers objectAtIndex:fakeUserIndex] valueForKey:@"subtitle2"];
    [self addSubview:self.radioSubtitle2];

    // likes
    self.radioLikes = [BundleStylesheet BSMakeLabel:[[BundleFileManager main] stylesheetForKey:@"RadioSelectionLikes" error:&error]];
    self.radioLikes.text = [NSString stringWithFormat:@"%d", [[gFakeUsers objectAtIndex:fakeUserIndex] valueForKey:@"likes"]];
    [self addSubview:self.radioLikes];

    // listeners
    self.radioListeners = [BundleStylesheet BSMakeLabel:[[BundleFileManager main] stylesheetForKey:@"RadioSelectionListeners" error:&error]];
    self.radioListeners.text = [NSString stringWithFormat:@"%d", [[gFakeUsers objectAtIndex:fakeUserIndex] valueForKey:@"listeners"]];
    [self addSubview:self.radioListeners];
    
    // configure selected view
    UIView* myBackView = [[UIView alloc] initWithFrame:self.frame];
    myBackView.backgroundColor = [UIColor colorWithRed:220.f/255.f green:227.f/255.f blue:239.f/255.f alpha:1];
    self.selectedBackgroundView = myBackView;
    [myBackView release];
    
    _maskBackup = self.radioAvatarMask.image;
    [_maskBackup retain];
    _maskSelected = [UIImage imageNamed:@"MaskSelected.png"];
    [_maskSelected retain];
    
  }
  return self;
}


- (void)dealloc
{
  [_maskBackup release];
  [_maskSelected release];
  [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];

  if (selected)
    self.radioAvatarMask.image = _maskSelected;
  else
    self.radioAvatarMask.image = _maskBackup;
}

@end
