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
        self.ffriend = nil;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.textColor = [UIColor whiteColor];
        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"FacebookFriendCell.image" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.image = [[WebImageView alloc] initWithFrame:sheet.frame];
        [self addSubview:self.image];
        
        sheet = [[Theme theme] stylesheetForKey:@"FacebookFriendCell.nameLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.nameLabel = [sheet makeLabel];
        [self addSubview:self.nameLabel];
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
    self.ffriend = facebookFriend;
    
    self.nameLabel.text = self.ffriend.name;

    NSDictionary* data = [self.ffriend.picture objectForKey:@"data"];
    NSString* urlstr = [data objectForKey:@"url"];
    
    NSURL* url = [NSURL URLWithString:urlstr];
    [self.image setUrl:url];
}


@end
