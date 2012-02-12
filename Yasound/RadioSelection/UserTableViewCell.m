//
//  RadioSelectionTableViewCell.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "UserTableViewCell.h"
#import "BundleFileManager.h"

@implementation UserTableViewCell

@synthesize user;
@synthesize userName;
@synthesize radioStatus;

@synthesize userAvatar;
@synthesize userAvatarMask;
@synthesize cellBackground;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier rowIndex:(NSInteger)rowIndex user:(User*)u;
{
  if (self = [super initWithFrame:frame reuseIdentifier:cellIdentifier]) 
  {
    BundleStylesheet* stylesheet;
    NSError* error;
    
      self.user = u;
      
      self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // cell background
    if (rowIndex & 1)
      self.cellBackground = [[[BundleFileManager main] stylesheetForKey:@"RadioSelectionBackgroundLight"  retainStylesheet:YES overwriteStylesheet:NO error:&error] makeImage];
    else
      self.cellBackground = [[[BundleFileManager main] stylesheetForKey:@"RadioSelectionBackgroundDark"  retainStylesheet:YES overwriteStylesheet:NO error:&error] makeImage];

    [self addSubview:self.cellBackground];
    
    // avatar
    NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:self.user.picture];
    self.userAvatar = [[WebImageView alloc] initWithImageAtURL:imageURL];
    stylesheet = [[BundleFileManager main] stylesheetForKey:@"RadioSelectionAvatar" retainStylesheet:YES overwriteStylesheet:NO error:&error];
    self.userAvatar.frame = stylesheet.frame;
    [self addSubview:self.userAvatar];
    
    // avatar mask
    NSString* avatarMask;
    if (rowIndex & 1)
      avatarMask = @"RadioSelectionMaskWhite";
    else
      avatarMask = @"RadioSelectionMaskGray";
    
    stylesheet = [[BundleFileManager main] stylesheetForKey:avatarMask  retainStylesheet:YES overwriteStylesheet:NO error:&error];
    self.userAvatarMask = [stylesheet makeImage];
    [self addSubview:self.userAvatarMask];
    
    // name
    self.userName = [[[BundleFileManager main] stylesheetForKey:@"RadioSelectionTitle"  retainStylesheet:YES overwriteStylesheet:NO error:&error] makeLabel];
    self.userName.text = self.user.name;
    [self addSubview:self.userName];
      
      // radio status
      self.radioStatus = [[[BundleFileManager main] stylesheetForKey:@"RadioSelectionSubtitle1"  retainStylesheet:YES overwriteStylesheet:NO error:&error] makeLabel];
      NSString* status;
      if (self.user.current_radio)
          status = [NSString stringWithFormat:@"listening to %@", self.user.current_radio.name];
      else if (self.user.own_radio)
          status = [NSString stringWithFormat:@"radio: %@", self.user.own_radio.name];
      self.radioStatus.text = status;
      [self addSubview:self.radioStatus];


    
    _maskBackup = self.userAvatarMask.image;
    [_maskBackup retain];
    _maskSelected = [UIImage imageNamed:@"CellRadioHighlighted_Mask.png"];
    [_maskSelected retain];
    
    _bkgBackup = self.cellBackground.image;
    [_bkgBackup retain];
    _bkgSelected = [UIImage imageNamed:@"CellRadioHighlighted.png"];
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
    self.userAvatarMask.image = _maskSelected;
   
    BundleStylesheet* sheet = [[BundleFileManager main] stylesheetForKey:@"RadioSelectionTitle" error:nil];
    [sheet applyToLabel:self.userName class:@"selected"];
  }
  else
  {
    self.cellBackground.image = _bkgBackup;
    self.userAvatarMask.image = _maskBackup;

    BundleStylesheet* sheet = [[BundleFileManager main] stylesheetForKey:@"RadioSelectionTitle" error:nil];
    [sheet applyToLabel:self.userName class:nil];
  }
}

@end
