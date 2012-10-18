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
@synthesize message;
@synthesize buttonLabel;

- (id)initWithFrame:(CGRect)frame messageId:(NSString*)messageId target:(id)target action:(SEL)action
{
    if (self = [super initWithFrame:frame])
    {
        self.target = target;
        self.action = action;

        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"commonNoisedBackground.png"]];
        
        self.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        // icon
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:[NSString stringWithFormat:@"BigMessage.Icons.%@", messageId] retainStylesheet:YES overwriteStylesheet:NO error:nil];
        [self addSubview:[sheet makeImage]];

        // build message label
        sheet = [[Theme theme] stylesheetForKey:@"BigMessage.message" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.message = [sheet makeLabel];
        NSString* messageText = [NSString stringWithFormat:@"BigMessage.Messages.%@", messageId];
        self.message.text = NSLocalizedString(messageText, nil);
        self.message.numberOfLines = 2;
        self.message.lineBreakMode = UILineBreakModeWordWrap;
        [self addSubview:self.message];

        // button
        sheet = [[Theme theme] stylesheetForKey:@"BigMessage.button" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.button = [sheet makeButton];
        if ((target != nil) && (action != nil))
            [self.button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
        
        // button label
        sheet = [[Theme theme] stylesheetForKey:@"BigMessage.buttonLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.buttonLabel = [sheet makeLabel];
        NSString* buttonText = [NSString stringWithFormat:@"BigMessage.ButtonLabels.%@", messageId];
        self.buttonLabel.text = NSLocalizedString(buttonText, nil);
        [self addSubview:self.buttonLabel];

        

    }
    
    return self;
    
}   



- (void)onButtonClicked:(id)sender
{
    // call delegate
    if (self.target)
        [self.target performSelector:self.action];
}




@end
