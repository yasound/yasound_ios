//
//  MenuTableViewCell.m
//  Yasound
//
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "MenuTableViewCell.h"
#import "BundleFileManager.h"
#import "Theme.h"

@implementation MenuTableViewCell

@synthesize name;
@synthesize icon;
@synthesize enabled = _enabled;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        _enabled = YES;
        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Menu.MenuViewCell_icon" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.icon = [[WebImageView alloc] initWithFrame:sheet.frame];
        [self addSubview:self.icon];
        
        sheet = [[Theme theme] stylesheetForKey:@"Menu.MenuViewCell_name" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.name = [sheet makeLabel];
        [self addSubview:self.name];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    
    if (enabled)
    {
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.name.textColor = [UIColor whiteColor];
    }
    else
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;    
        self.name.textColor = [UIColor grayColor];
    }
    
}


@end
