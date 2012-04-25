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


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MenuViewCell_icon" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.icon = [[WebImageView alloc] initWithFrame:sheet.frame];
        
        sheet = [[Theme theme] stylesheetForKey:@"MenuViewCell_name" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.name = [sheet makeLabel];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
