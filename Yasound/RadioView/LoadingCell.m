//
//  LoadingCell.m
//  Yasound
//
//  Created by matthieu campion on 4/19/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "LoadingCell.h"

@implementation LoadingCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier
{
    self = [super initWithFrame:frame reuseIdentifier:CellIdentifier];
    if (self) 
    {    
        UIView* view = self.contentView;
        
        // activity indicator
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicator.frame = CGRectMake(90, 13, 18, 18);
        [indicator startAnimating];
        [view addSubview:indicator];
        
        // label
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(120, 12, 150, 20)];
        label.text = NSLocalizedString(@"RadioView_loading_previous_events_message", nil);
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        [view addSubview:label];
    }
    return self;
}

@end
