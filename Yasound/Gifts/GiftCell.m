//
//  GiftCell.m
//  Yasound
//
//  Created by mat on 06/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "GiftCell.h"
#import "Theme.h"

@implementation GiftCell

@synthesize gift = _gift;
@synthesize image;
@synthesize mask;
@synthesize label;
@synthesize description;
@synthesize date;
@synthesize count;
@synthesize done;
@synthesize disabledLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _gift = nil;
        
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.cellImage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.image = [[WebImageView alloc] initWithFrame:sheet.frame];
        [self addSubview:self.image];
        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.cellImageMask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.mask = [sheet makeImage];
        [self addSubview:self.mask];
        
        sheet = [[Theme theme] stylesheetForKey:@"Gift.name" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.label = [sheet makeLabel];
        [self addSubview:self.label];
        
        sheet = [[Theme theme] stylesheetForKey:@"Gift.description" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.description = [sheet makeLabel];
        self.description.numberOfLines = 2;
        [self addSubview:self.description];
        
        sheet = [[Theme theme] stylesheetForKey:@"Gift.date" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.date = [sheet makeLabel];
        [self addSubview:self.date];
        
        sheet = [[Theme theme] stylesheetForKey:@"Gift.count" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.count = [sheet makeLabel];
        [self addSubview:self.count];
        
        sheet = [[Theme theme] stylesheetForKey:@"Gift.done" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.done = [sheet makeLabel];
        [self addSubview:self.done];
        
        sheet = [[Theme theme] stylesheetForKey:@"Gift.disabled" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.disabledLabel = [sheet makeLabel];
        [self addSubview:self.disabledLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if ([self.gift.enabled boolValue])
        [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setGift:(Gift*)gift
{
    _gift = gift;
    
    NSString* dateString = nil;
    NSString* countString = nil;
    NSString* doneString = nil;
    NSString* disabledString = nil;
    if (![self.gift.enabled boolValue])
    {
        dateString = nil;
        countString = nil;
        doneString = nil;
        disabledString = NSLocalizedString(@"GiftDisabled", nil);
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    else if ([self.gift hasBeenFullyWon])
    {
        dateString = [self.gift formattedDate];
        countString = nil;
        doneString = NSLocalizedString(@"GiftDone", nil);
        disabledString = nil;
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        dateString = nil;
        countString = [self.gift countProgress];
        doneString = nil;
        disabledString = nil;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    
    self.label.text = self.gift.name;
    self.description.text = self.gift.description;
    self.image.url = [NSURL URLWithString:self.gift.picture_url];
    self.date.text = dateString;
    self.count.text = countString;
    self.done.text = doneString;
    self.disabledLabel.text = disabledString;
    
    if ([self.gift canBeWon])
        self.selectionStyle = UITableViewCellSelectionStyleGray;
    else
        self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
