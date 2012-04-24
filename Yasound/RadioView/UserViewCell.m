//
//  UserViewCell.m
//  Yasound
//
//  Created by matthieu campion on 2/3/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "UserViewCell.h"
#import "Theme.h"
#import "YasoundDataProvider.h"

#import <QuartzCore/QuartzCore.h>


@implementation UserViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
      _user = nil;
      
      BundleStylesheet* imageSheet = [[Theme theme] stylesheetForKey:@"CellAvatar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
      BundleStylesheet* nameSheet = [[Theme theme] stylesheetForKey:@"StatusBarUserName" retainStylesheet:YES overwriteStylesheet:NO error:nil];
      
      CGRect nameRect = nameSheet.frame;
      CGRect imageRect = imageSheet.frame;
      
      CGRect nameRect2 = CGRectMake(USER_VIEW_CELL_BORDER, nameRect.origin.y +4, nameRect.size.width, nameRect.size.height);
      CGRect imageRect2 = CGRectMake(nameRect2.origin.x + nameRect2.size.width / 2.f - imageRect.size.width / 2.f, imageRect.origin.y +4, imageRect.size.width, imageRect.size.height);
      
      _avatarView = [[WebImageView alloc] initWithFrame:imageRect];
        
        
        _avatarView.layer.masksToBounds = YES;
        _avatarView.layer.cornerRadius = 6;

      UIFont* font = [nameSheet makeFont];
      _nameLabel = [nameSheet makeLabel];
      _nameLabel.font = font;
      
      _nameLabel.frame = nameRect2;
      _avatarView.frame = imageRect2;
      
      [self.contentView addSubview:_avatarView];
      [self.contentView addSubview:_nameLabel]; 
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)update
{ 
  // avatar
  if (_user.picture == nil)
  {
    _avatarView.url = nil;
  }
  else
  {
    NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:_user.picture];
    _avatarView.url = imageURL;
  }  
  // name label
  _nameLabel.text = _user.name;
}

- (User*)user
{
  return _user;
}

- (void)setUser:(User *)user
{
  _user = user;
  [self update];
}

@end
