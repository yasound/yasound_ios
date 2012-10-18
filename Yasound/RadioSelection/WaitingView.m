//
//  WaitingView.m
//  Yasound
//
//  Created by mat on 13/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "WaitingView.h"
#import "Theme.h"

@implementation WaitingView

- (id)initWithText:(NSString*)text
{
    self = [super init];
    if (self)
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"WaitingView.container" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.frame = sheet.frame;
        self.backgroundColor = sheet.color;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 6;
        self.layer.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2].CGColor;
        self.layer.borderWidth = 1.0;
        self.layer.backgroundColor = sheet.color.CGColor;
        
        sheet = [[Theme theme] stylesheetForKey:@"WaitingView.activityIndicator" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.frame = sheet.frame;

        [_indicator startAnimating];
        [self addSubview:_indicator];
        
        if (text)
        {
            sheet = [[Theme theme] stylesheetForKey:@"WaitingView.title" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            _label = [sheet makeLabel];
            _label.text = text;
            _label.numberOfLines = 2;
            [self addSubview:_label];
        }
        else
            _label = nil;
        
        self.alpha = 0.85;
        
        
        
    }
    return self;
}

- (void)dealloc
{
    [_indicator stopAnimating];
    [super dealloc];
}



@end
