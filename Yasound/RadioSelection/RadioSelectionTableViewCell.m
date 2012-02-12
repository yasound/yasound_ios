//
//  RadioSelectionTableViewCell.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioSelectionTableViewCell.h"
#import "BundleFileManager.h"

@interface RadioSelectionTableViewCell (internal_update)

- (void)onUpdate:(NSTimer*)timer;

@end

@implementation RadioSelectionTableViewCell

@synthesize radio;
@synthesize radioTitle;
@synthesize radioSubtitle1;
@synthesize radioSubtitle2;
@synthesize radioLikes;
@synthesize radioListeners;
@synthesize radioAvatar;
@synthesize radioAvatarMask;
//@synthesize cellBackground;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier rowIndex:(NSInteger)rowIndex radio:(Radio*)r;
{
  if (self = [super initWithFrame:frame reuseIdentifier:cellIdentifier]) 
  {
    BundleStylesheet* stylesheet;
    NSError* error;
      
      self.selectionStyle = UITableViewCellSelectionStyleNone;
    
      self.radio = r;
    
//    // cell background
//    if (rowIndex & 1)
//    {
//        UIImageView* imageView = [[[BundleFileManager main] stylesheetForKey:@"RadioSelectionBackgroundLight"  retainStylesheet:YES overwriteStylesheet:NO error:nil] makeImage];
//        self.cellBackground = imageView;
//    }
//    else
//    {
//        UIImageView* imageView = [[[BundleFileManager main] stylesheetForKey:@"RadioSelectionBackgroundDark"  retainStylesheet:YES overwriteStylesheet:NO error:nil] makeImage];
//        self.cellBackground = imageView;
//    }

//    [self addSubview:self.cellBackground];
    
    // avatar
    NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:self.radio.picture];
    self.radioAvatar = [[WebImageView alloc] initWithImageAtURL:imageURL];
    stylesheet = [[BundleFileManager main] stylesheetForKey:@"RadioSelectionAvatar" retainStylesheet:YES overwriteStylesheet:NO error:&error];
    self.radioAvatar.frame = stylesheet.frame;
    [self addSubview:self.radioAvatar];
    
    // avatar mask
    NSString* avatarMask;
    if (rowIndex & 1)
      avatarMask = @"RadioSelectionMaskWhite";
    else
      avatarMask = @"RadioSelectionMaskGray";
    
    stylesheet = [[BundleFileManager main] stylesheetForKey:avatarMask  retainStylesheet:YES overwriteStylesheet:NO error:&error];
    self.radioAvatarMask = [stylesheet makeImage];
    [self addSubview:self.radioAvatarMask];
    
    // title
    self.radioTitle = [[[BundleFileManager main] stylesheetForKey:@"RadioSelectionTitle"  retainStylesheet:YES overwriteStylesheet:NO error:&error] makeLabel];
    self.radioTitle.text = self.radio.name;
    [self addSubview:self.radioTitle];

    // subtitle 1
    self.radioSubtitle1 = [[[BundleFileManager main] stylesheetForKey:@"RadioSelectionSubtitle1"  retainStylesheet:YES overwriteStylesheet:NO error:&error] makeLabel];
      self.radioSubtitle1.text = @"";
    [self addSubview:self.radioSubtitle1];

    // subtitle 2
    self.radioSubtitle2 = [[[BundleFileManager main] stylesheetForKey:@"RadioSelectionSubtitle2"  retainStylesheet:YES overwriteStylesheet:NO error:&error] makeLabel];
      self.radioSubtitle2.text = @"";
    [self addSubview:self.radioSubtitle2];

    // likes
    self.radioLikes = [[[BundleFileManager main] stylesheetForKey:@"RadioSelectionLikes"  retainStylesheet:YES overwriteStylesheet:NO error:&error] makeLabel];
    self.radioLikes.text = [NSString stringWithFormat:@"%d", [self.radio.favorites integerValue]];
    [self addSubview:self.radioLikes];

    // listeners
    self.radioListeners = [[[BundleFileManager main] stylesheetForKey:@"RadioSelectionListeners"  retainStylesheet:YES overwriteStylesheet:NO error:&error] makeLabel];
    self.radioListeners.text = [NSString stringWithFormat:@"%d", [self.radio.nb_current_users integerValue]];
    [self addSubview:self.radioListeners];
    
    // configure selected view
//    UIView* myBackView = [[UIView alloc] initWithFrame:self.frame];
//    myBackView.backgroundColor = [UIColor colorWithRed:220.f/255.f green:227.f/255.f blue:239.f/255.f alpha:1];
//    self.selectedBackgroundView = myBackView;
//    [myBackView release];
    
    _maskBackup = self.radioAvatarMask.image;
    [_maskBackup retain];
    _maskSelected = [UIImage imageNamed:@"CellRadioHighlighted_Mask.png"];
    [_maskSelected retain];
    
//    _bkgBackup = self.cellBackground.image;
//    [_bkgBackup retain];
//    _bkgSelected = [UIImage imageNamed:@"CellRadioHighlighted.png"];
//    [_bkgSelected retain];

    
    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(onUpdate:) userInfo:nil repeats:YES];
    [_updateTimer fire];
  }
  return self;
}



- (void)willMoveToSuperview:(UIView *)newSuperview 
{
    [super willMoveToSuperview:newSuperview];
    if(!newSuperview) 
    {
        [_updateTimer invalidate];
    }
}




- (void)updateWithRadio:(Radio*)radio rowIndex:(NSInteger)rowIndex
{
    self.radio = radio;
    
    BundleStylesheet* sheet = nil;
    
//    if (rowIndex & 1)
//        sheet = [[BundleFileManager main] stylesheetForKey:@"RadioSelectionBackgroundLight"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    else
//        sheet = [[BundleFileManager main] stylesheetForKey:@"RadioSelectionBackgroundDark"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    
//    [self.cellBackground setImage:[sheet image]];
    

    
    // avatar
    NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:self.radio.picture];
    [self.radioAvatar setUrl:imageURL];
    
    // avatar mask
    NSString* avatarMask;
    if (rowIndex & 1)
        avatarMask = @"RadioSelectionMaskWhite";
    else
        avatarMask = @"RadioSelectionMaskGray";
    
    sheet = [[BundleFileManager main] stylesheetForKey:avatarMask  retainStylesheet:YES overwriteStylesheet:NO error:nil];
    [self.radioAvatarMask setImage:[sheet image]];
    
    // title
    self.radioTitle.text = self.radio.name;
    
    // subtitle 1
    self.radioSubtitle1.text = @"";
    
    // subtitle 2
    self.radioSubtitle2.text = @"";

    
    // likes
    self.radioLikes.text = [NSString stringWithFormat:@"%d", [self.radio.favorites integerValue]];
    
    // listeners
    self.radioListeners.text = [NSString stringWithFormat:@"%d", [self.radio.nb_current_users integerValue]];
    
    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(onUpdate:) userInfo:nil repeats:YES];
    [_updateTimer fire];
    
    
}




- (void)dealloc
{
  [_updateTimer invalidate];
  [_maskBackup release];
  [_maskSelected release];
  [_bkgBackup release];
  [_bkgSelected release];
  [super dealloc];
}

- (void)receivedCurrentSong:(Song*)song withInfo:(NSDictionary*)info
{
  if (!song)
    return;
  
  self.radioSubtitle1.text = song.artist;
  self.radioSubtitle2.text = song.name;
}

- (void)onUpdate:(NSTimer*)timer
{
  [[YasoundDataProvider main] currentSongForRadio:self.radio target:self action:@selector(receivedCurrentSong:withInfo:)];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];

  if (selected)
  {
//    self.cellBackground.image = _bkgSelected;
//    self.radioAvatarMask.image = _maskSelected;
   
//    BundleStylesheet* sheet = [[BundleFileManager main] stylesheetForKey:@"RadioSelectionTitle" error:nil];
//    [sheet applyToLabel:self.radioTitle class:@"selected"];
//
//    sheet = [[BundleFileManager main] stylesheetForKey:@"RadioSelectionSubtitle1" error:nil];
//    [sheet applyToLabel:self.radioSubtitle1 class:@"selected"];
//
//    sheet = [[BundleFileManager main] stylesheetForKey:@"RadioSelectionSubtitle2" error:nil];
//    [sheet applyToLabel:self.radioSubtitle2 class:@"selected"];
//
//    sheet = [[BundleFileManager main] stylesheetForKey:@"RadioSelectionLikes" error:nil];
//    [sheet applyToLabel:self.radioLikes class:@"selected"];
//
//    sheet = [[BundleFileManager main] stylesheetForKey:@"RadioSelectionListeners" error:nil];
//    [sheet applyToLabel:self.radioListeners class:@"selected"];
  }
  else
  {
//    self.cellBackground.image = _bkgBackup;
//    self.radioAvatarMask.image = _maskBackup;

//    BundleStylesheet* sheet = [[BundleFileManager main] stylesheetForKey:@"RadioSelectionTitle" error:nil];
//    [sheet applyToLabel:self.radioTitle class:nil];
//    
//    sheet = [[BundleFileManager main] stylesheetForKey:@"RadioSelectionSubtitle1" error:nil];
//    [sheet applyToLabel:self.radioSubtitle1 class:nil];
//    
//    sheet = [[BundleFileManager main] stylesheetForKey:@"RadioSelectionSubtitle2" error:nil];
//    [sheet applyToLabel:self.radioSubtitle2 class:nil];
//    
//    sheet = [[BundleFileManager main] stylesheetForKey:@"RadioSelectionLikes" error:nil];
//    [sheet applyToLabel:self.radioLikes class:nil];
//    
//    sheet = [[BundleFileManager main] stylesheetForKey:@"RadioSelectionListeners" error:nil];
//    [sheet applyToLabel:self.radioListeners class:nil];
  }
}

@end
