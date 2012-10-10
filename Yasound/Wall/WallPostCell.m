//
//  WallPostCell.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//
//

#import "WallPostCell.h"


@implementation WallPostCell

@synthesize fixed;
@synthesize textfield;
@synthesize button;
@synthesize label;


- (void)awakeFromNib
{
    self.fixed = NO;
    self.textfield.placeholder = NSLocalizedString(@"Wall.postBar.placeholder", nil);
    self.label.text = NSLocalizedString(@"Wall.postBar.label", nil);
}



@end


