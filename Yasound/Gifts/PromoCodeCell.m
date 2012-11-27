//
//  PromoCodeCell.m
//  Yasound
//
//  Created by mat on 13/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "PromoCodeCell.h"
#import "Theme.h"
#import "YasoundSessionManager.h"
#import "RootViewController.h"

#import "TapjoyConnect.h"

@implementation PromoCodeCell
@synthesize promoCodeDelegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _label = nil;
        _textField = nil;
        [self reset];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (![YasoundSessionManager main].registered)
        [super setSelected:selected animated:animated];
}

- (void)reset
{
    if (_label)
    {
        [_label removeFromSuperview];
        [_label release];
    }
    if (_textField)
    {
        [_textField removeFromSuperview];
        [_textField release];
    }
    
    
    
    if ([YasoundSessionManager main].registered)
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Gift.promptPromo" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        _label = [sheet makeLabel];
        [self addSubview:_label];
        _label.text = NSLocalizedString(@"HdPromoCodePrompt", nil);
        self.accessoryType = UITableViewCellAccessoryNone;
        
        sheet = [[Theme theme] stylesheetForKey:@"Gift.textFieldPromo" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        _textField = [[UITextField alloc] initWithFrame:sheet.frame];
        _textField.delegate = self;
        _textField.borderStyle = UITextBorderStyleRoundedRect;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self addSubview:_textField];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Gift.promptPromoNotLoggued" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        _label = [sheet makeLabel];
        _label.numberOfLines = 2;
        _label.text = NSLocalizedString(@"HdPromoCodePromptNotLoggued", nil);
        [self addSubview:_label];
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField != _textField)
        return NO;
    
    [textField resignFirstResponder];

[TapjoyConnect showOffers];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.promoCodeDelegate)
        [self.promoCodeDelegate promoCodeEntered:textField.text];
}


@end
