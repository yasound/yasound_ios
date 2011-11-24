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

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier rowIndex:(NSInteger)rowIndex
{
  if (self = [super initWithFrame:frame reuseIdentifier:cellIdentifier]) 
  {
    BundleStylesheet* stylesheet;
    NSError* error;
    
    // cell background
    [self addSubview:[BundleStylesheet BSMakeImage:[[BundleFileManager main] stylesheetForKey:@"RadioSelectionBackground" error:&error]]];
  
    // avatar
    self.radioAvatar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatarDummy.png"]];
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
    [self addSubview:self.radioTitle];

    // subtitle 1
    self.radioSubtitle1 = [BundleStylesheet BSMakeLabel:[[BundleFileManager main] stylesheetForKey:@"RadioSelectionSubtitle1" error:&error]];
    [self addSubview:self.radioSubtitle1];

    // subtitle 2
    self.radioSubtitle2 = [BundleStylesheet BSMakeLabel:[[BundleFileManager main] stylesheetForKey:@"RadioSelectionSubtitle2" error:&error]];
    [self addSubview:self.radioSubtitle2];

    // likes
    self.radioLikes = [BundleStylesheet BSMakeLabel:[[BundleFileManager main] stylesheetForKey:@"RadioSelectionLikes" error:&error]];
    [self addSubview:self.radioLikes];

    // listeners
    self.radioListeners = [BundleStylesheet BSMakeLabel:[[BundleFileManager main] stylesheetForKey:@"RadioSelectionListeners" error:&error]];
    [self addSubview:self.radioListeners];
    
      
    //  if (gGrayMask == nil)
    //    gGrayMask = [UIImage imageNamed:@"MaskGray.png"];
    //  

//    if (rowIndex & 1)
//    {
//      self.backgroundColor = [UIColor redColor];
////      [cell.radioAvatarMask setImage:[UIImage imageNamed:@"coeur.png"]];
////      NSLog(@"log : %@", cell.radioTitle.text);
//    }
    
  }
  return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];
  
  // Configure the view for the selected state
}

@end
