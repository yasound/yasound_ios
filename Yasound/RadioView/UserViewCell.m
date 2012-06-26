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
      
        BundleStylesheet* imageSheet = [[Theme theme] stylesheetForKey:@"Wall.Messages.CellAvatar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        BundleStylesheet* maskSheet = [[Theme theme] stylesheetForKey:@"Wall.Messages.CellAvatarMask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
      BundleStylesheet* nameSheet = [[Theme theme] stylesheetForKey:@"Wall.Status.StatusBarUserName" retainStylesheet:YES overwriteStylesheet:NO error:nil];
      
      CGRect nameRect = nameSheet.frame;
        CGRect imageRect = imageSheet.frame;
        CGRect maskRect = maskSheet.frame;
      
      CGRect nameRect2 = CGRectMake(USER_VIEW_CELL_BORDER, nameRect.origin.y +4, nameRect.size.width, nameRect.size.height);
        CGRect imageRect2 = CGRectMake(nameRect2.origin.x + nameRect2.size.width / 2.f - imageRect.size.width / 2.f, imageRect.origin.y +4, imageRect.size.width, imageRect.size.height);
        CGRect maskRect2 = CGRectMake(imageRect2.origin.x - 1, imageRect2.origin.y - 1, maskRect.size.width, maskRect.size.height);
      
      _avatarView = [[WebImageView alloc] initWithFrame:imageRect];
        
        
        // draw circle mask
        _avatarView.layer.masksToBounds = YES;
        _avatarView.layer.cornerRadius = 17.5;
        
        // avatar circled mask
        _avatarMask = [[UIImageView alloc] initWithImage:[maskSheet image]];


      UIFont* font = [nameSheet makeFont];
      _nameLabel = [nameSheet makeLabel];
      _nameLabel.font = font;
      
      _nameLabel.frame = nameRect2;
      _avatarView.frame = imageRect2;
        _avatarMask.frame = maskRect2;
      
        [self.contentView addSubview:_avatarView];
        [self.contentView addSubview:_avatarMask];
      [self.contentView addSubview:_nameLabel]; 
    }
    return self;
}


//- (UIImage *)imageByDrawingCircleOnImage:(UIImage *)image
//{
//	// begin a graphics context of sufficient size
//	UIGraphicsBeginImageContext(image.size);
//    
//	// draw original image into the context
//	[image drawAtPoint:CGPointZero];
//    
//	// get the context for CoreGraphics
//	CGContextRef ctx = UIGraphicsGetCurrentContext();
//    
//	// set stroking color and draw circle
//	[[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1] setStroke];
//    CGContextSetLineWidth(ctx, 5.0);
//    
//	// make circle rect 1 px from border
//	CGRect circleRect = CGRectMake(0, 0,  image.size.width, image.size.height);
//	circleRect = CGRectInset(circleRect, 3, 3);
//    
//	// draw circle
//	CGContextStrokeEllipseInRect(ctx, circleRect);
//    
//	// make image out of bitmap context
//	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//	// free the context
//	UIGraphicsEndImageContext();
//    
//	return retImage;
//}


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
