//
//  FacebookFriendTableViewCell.m
//  Yasound
//
//  Created by mat on 25/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "FacebookFriendTableViewCell.h"
#import "Theme.h"

@implementation FacebookFriendTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _friend = nil;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.textColor = [UIColor whiteColor];
        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"FacebookFriendCell.image" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        _image = [[WebImageView alloc] initWithFrame:sheet.frame];
        [self addSubview:_image];
        
        sheet = [[Theme theme] stylesheetForKey:@"FacebookFriendCell.nameLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        _nameLabel = [sheet makeLabel];
        [self addSubview:_nameLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateWithFacebookFriend:(FacebookFriend*)facebookFriend
{
    _friend = facebookFriend;
    _nameLabel.text = _friend.name;
    
    _image.url = [NSURL URLWithString:_friend.picture];
}


@end
