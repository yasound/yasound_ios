//
//  BigMessageView.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "BigMessageView.h"
#import "Theme.h"

@implementation BigMessageView

@synthesize target;
@synthesize action;


- (id)initWithFrame:(CGRect)frame message:(NSString*)message actionTitle:(NSString*)actionTitle target:(id)target action:(SEL)action
{
    self.target = target;
    self.action = action;
    
    self.frame = frame;
    
    // build message label
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"BigMessage.message" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [sheet makeLabel];
    CGFloat labelWidth = self.frame.size.width -20;
    label.text = message;
    [self addSubview:label];
    
    CGSize suggestedSize = [message sizeWithFont:[sheet makeFont] constrainedToSize:CGSizeMake(labelWidth, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    
    // build action button
    UIButton* button = nil;
    UIImageView* buttonLeft = nil;
    UIImageView* buttonRight = nil;
    if (actionTitle != nil)
    {
        // create button
        sheet = [[Theme theme] stylesheetForKey:@"BigMessage.button" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        button = [sheet makeButton];
        [self addSubview:button];

        // compute width
        CGSize buttonSuggestedSize = [actionTitle sizeWithFont:[sheet makeFont] constrainedToSize:CGSizeMake(labelWidth, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        CGFloat buttonWidth = buttonSuggestedSize.width + 16;
        
        // define button frame
        CGRect buttonFrame = CGRectMake(self.frame.size.width / 2.f - buttonWidth / 2.f, 0, buttonWidth, button.frame.size.height);
        button.frame = buttonFrame;
        
        // add visual corners to the button, to make a rounded button
        sheet = [[Theme theme] stylesheetForKey:@"BigMessage.buttonLeft" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        buttonLeft = [sheet makeImage];
        CGRect frame = CGRectMake(buttonFrame.origin.x - buttonLeft.frame.size.width, 0, buttonLeft.frame.size.width, buttonLeft.frame.size.height);
        buttonLeft.frame = frame;
        [self addSubview:buttonLeft];

        sheet = [[Theme theme] stylesheetForKey:@"BigMessage.buttonRight" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        buttonRight = [sheet makeImage];
        frame = CGRectMake(buttonFrame.origin.x + buttonFrame.size.width + buttonRight.frame.size.width, 0, buttonRight.frame.size.width, buttonRight.frame.size.height);
        buttonRight.frame = frame;
        [self addSubview:buttonRight];        
    }
    
    
    ICI
    
    
    
}   




@end
