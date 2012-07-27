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
@synthesize button;
@synthesize buttonLeft;
@synthesize buttonRight;
@synthesize buttonLabel;

- (id)initWithFrame:(CGRect)frame message:(NSString*)message actionTitle:(NSString*)actionTitle target:(id)target action:(SEL)action
{
    if (self = [super initWithFrame:frame])
    {
        self.target = target;
        self.action = action;
        
        self.backgroundColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:240.f/255.f alpha:1];
        
        self.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        
        // build message label
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"BigMessage.message" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UILabel* label = [sheet makeLabel];
        CGFloat labelWidth = self.frame.size.width -20;
        label.text = message;
        [self addSubview:label];
        
        CGSize suggestedSize = [message sizeWithFont:[sheet makeFont] constrainedToSize:CGSizeMake(labelWidth, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        label.frame = CGRectMake(self.frame.size.width / 2.f - labelWidth / 2.f, 0, labelWidth, suggestedSize.height + 16);
        
        // build action button
        if (actionTitle != nil)
        {
            // preload images
            sheet = [[Theme theme] stylesheetForKey:@"BigMessage.button" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            sheet = [[Theme theme] stylesheetForKey:@"BigMessage.buttonLeft" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            sheet = [[Theme theme] stylesheetForKey:@"BigMessage.buttonRight" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            sheet = [[Theme theme] stylesheetForKey:@"BigMessage.buttonSelected" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            sheet = [[Theme theme] stylesheetForKey:@"BigMessage.buttonLeftSelected" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            sheet = [[Theme theme] stylesheetForKey:@"BigMessage.buttonRightSelected" retainStylesheet:YES overwriteStylesheet:NO error:nil];

            // button height
            sheet = [[Theme theme] stylesheetForKey:@"BigMessage.button" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            UIImage* imageButtonUp = [sheet image];
            
            sheet = [[Theme theme] stylesheetForKey:@"BigMessage.buttonLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            

            // compute width
            CGSize buttonSuggestedSize = [actionTitle sizeWithFont:[sheet makeFont] constrainedToSize:CGSizeMake(labelWidth, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
            CGFloat buttonWidth = buttonSuggestedSize.width + 16;
            CGFloat buttonHeight = imageButtonUp.size.height;
            // define button frame
            CGRect buttonFrame = CGRectMake(self.frame.size.width / 2.f - buttonWidth / 2.f, 0, buttonWidth, buttonHeight);

            // create button
            self.button = [[InteractiveView alloc] initWithFrame:buttonFrame target:self action:@selector(onButtonPressedUp:) withObject:nil];
            [self.button setTargetOnTouchDown:self action:@selector(onButtonPressedDown:)];
            
            self.button.backgroundColor = [UIColor colorWithPatternImage:imageButtonUp];
            [self addSubview:self.button];
            
            // with label
            self.buttonLabel = [sheet makeLabel];
            self.buttonLabel.text = actionTitle;
            self.buttonLabel.frame = CGRectMake(0, buttonHeight / 2.f - 16.f / 2.f, buttonWidth, 16);
            [self.button addSubview:self.buttonLabel];

            
            // add visual corners to the button, to make a rounded button
            sheet = [[Theme theme] stylesheetForKey:@"BigMessage.buttonLeft" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            self.buttonLeft = [sheet makeImage];
            CGRect frame = CGRectMake(buttonFrame.origin.x - self.buttonLeft.frame.size.width, 0, self.buttonLeft.frame.size.width, self.buttonLeft.frame.size.height);
            self.buttonLeft.frame = frame;
            [self addSubview:self.buttonLeft];

            sheet = [[Theme theme] stylesheetForKey:@"BigMessage.buttonRight" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            self.buttonRight = [sheet makeImage];
            frame = CGRectMake(buttonFrame.origin.x + buttonFrame.size.width, 0, self.buttonRight.frame.size.width, self.buttonRight.frame.size.height);
            self.buttonRight.frame = frame;
            [self addSubview:self.buttonRight];        
        }
        
        CGFloat spacing = 16;
        
        // contentHeight = message height + spacing + button height
        CGFloat contentsHeight = label.frame.size.height + spacing + self.button.frame.size.height;
        
        // => y for the label
        CGFloat labelY = self.frame.size.height / 2.f - contentsHeight / 2.f;
        
        // => y for the button
        CGFloat buttonY = labelY + label.frame.size.height + spacing;
        
        // we can set the frames properly now
        label.frame = CGRectMake(label.frame.origin.x, labelY, label.frame.size.width, label.frame.size.height);
        self.button.frame = CGRectMake(self.button.frame.origin.x, buttonY, self.button.frame.size.width, self.button.frame.size.height);
        self.buttonLeft.frame = CGRectMake(self.buttonLeft.frame.origin.x, buttonY, self.buttonLeft.frame.size.width, self.buttonLeft.frame.size.height);
        self.buttonRight.frame = CGRectMake(self.buttonRight.frame.origin.x, buttonY, self.buttonRight.frame.size.width, self.buttonRight.frame.size.height);
    }
    
    return self;
    
}   


- (void)onButtonPressedDown:(id)sender
{
    // stylesheet
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"BigMessage.buttonSelected" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.button.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
    
    sheet = [[Theme theme] stylesheetForKey:@"BigMessage.buttonLeftSelected" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.buttonLeft.image = [sheet image];
    
    sheet = [[Theme theme] stylesheetForKey:@"BigMessage.buttonRightSelected" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.buttonRight.image = [sheet image];
    
    
    sheet = [[Theme theme] stylesheetForKey:@"BigMessage.buttonLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    [sheet applyToLabel:self.buttonLabel class:@"selected"];
}


- (void)onButtonPressedUp:(id)sender
{

    // stylesheet
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"BigMessage.button" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.button.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
    
    sheet = [[Theme theme] stylesheetForKey:@"BigMessage.buttonLeft" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.buttonLeft.image = [sheet image];
    
    sheet = [[Theme theme] stylesheetForKey:@"BigMessage.buttonRight" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.buttonRight.image = [sheet image];

    sheet = [[Theme theme] stylesheetForKey:@"BigMessage.buttonLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    [sheet applyToLabel:self.buttonLabel class:@"default"];
    
    // call delegate
    if (self.target)
        [self.target performSelector:self.action];
}




@end
