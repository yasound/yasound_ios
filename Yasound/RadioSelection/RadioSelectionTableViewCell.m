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
@synthesize cellBackground;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier rowIndex:(NSInteger)rowIndex data:(NSDictionary*)data;
{
  if (self = [super initWithFrame:frame reuseIdentifier:cellIdentifier]) 
  {
    BundleStylesheet* stylesheet;
    NSError* error;
    
    
    // cell background
    if (rowIndex & 1)
      self.cellBackground = [[[BundleFileManager main] stylesheetForKey:@"RadioSelectionBackgroundDark" error:&error] makeImage];
    else
      self.cellBackground = [[[BundleFileManager main] stylesheetForKey:@"RadioSelectionBackgroundLight" error:&error] makeImage];

    [self addSubview:self.cellBackground];
    
    // avatar
    self.radioAvatar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[data valueForKey:@"image"]]];
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
    self.radioAvatarMask = [stylesheet makeImage];
    [self addSubview:self.radioAvatarMask];
    
    // title
    self.radioTitle = [[[BundleFileManager main] stylesheetForKey:@"RadioSelectionTitle" error:&error] makeLabel];
    self.radioTitle.text = [data valueForKey:@"title"];
    [self addSubview:self.radioTitle];

    // subtitle 1
    self.radioSubtitle1 = [[[BundleFileManager main] stylesheetForKey:@"RadioSelectionSubtitle1" error:&error] makeLabel];
    self.radioSubtitle1.text = [data valueForKey:@"subtitle1"];
    [self addSubview:self.radioSubtitle1];

    // subtitle 2
    self.radioSubtitle2 = [[[BundleFileManager main] stylesheetForKey:@"RadioSelectionSubtitle2" error:&error] makeLabel];
    self.radioSubtitle2.text = [data valueForKey:@"subtitle2"];
    [self addSubview:self.radioSubtitle2];

    // likes
    self.radioLikes = [[[BundleFileManager main] stylesheetForKey:@"RadioSelectionLikes" error:&error] makeLabel];
    self.radioLikes.text = [NSString stringWithFormat:@"%d", [[data valueForKey:@"likes"] integerValue]];
    [self addSubview:self.radioLikes];

    // listeners
    self.radioListeners = [[[BundleFileManager main] stylesheetForKey:@"RadioSelectionListeners" error:&error] makeLabel];
    self.radioListeners.text = [NSString stringWithFormat:@"%d", [[data valueForKey:@"listeners"] integerValue]];
    [self addSubview:self.radioListeners];
    
    // configure selected view
//    UIView* myBackView = [[UIView alloc] initWithFrame:self.frame];
//    myBackView.backgroundColor = [UIColor colorWithRed:220.f/255.f green:227.f/255.f blue:239.f/255.f alpha:1];
//    self.selectedBackgroundView = myBackView;
//    [myBackView release];
    
    _maskBackup = self.radioAvatarMask.image;
    [_maskBackup retain];
    _maskSelected = [UIImage imageNamed:@"MaskSelected.png"];
    [_maskSelected retain];
    
    _bkgBackup = self.cellBackground.image;
    [_bkgBackup retain];
    _bkgSelected = [UIImage imageNamed:@"CellBackgroundBlue.png"];
    [_bkgSelected retain];

    
  }
  return self;
}


- (void)dealloc
{
  [_maskBackup release];
  [_maskSelected release];
  [_bkgBackup release];
  [_bkgSelected release];
  [super dealloc];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];

  if (selected)
  {
    self.cellBackground.image = _bkgSelected;
    self.radioAvatarMask.image = _maskSelected;
    
    
  }
  else
  {
    self.cellBackground.image = _bkgBackup;
    self.radioAvatarMask.image = _maskBackup;
  }
}

@end
