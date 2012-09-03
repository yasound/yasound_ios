//
//  CustomSizedButtonView
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "CustomSizedButtonView.h"
#import "Theme.h"


@implementation CustomSizedButtonView

#define LEFT_BORDER 14
#define RIGHT_BORDER 10

@synthesize themeRef;
@synthesize left;
@synthesize right;
@synthesize center;
@synthesize target;
@synthesize action;


- (id)initWithThemeRef:(NSString*)aThemeRef title:(NSString*)title {

    if (self = [super init]) {
        
        self.themeRef = aThemeRef;
    
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:[NSString stringWithFormat:@"CustomSizedButtonView.%@.title", themeRef] retainStylesheet:YES overwriteStylesheet:YES error:nil];
        
        CGSize suggestedSize = [title sizeWithFont:[sheet makeFont] constrainedToSize:CGSizeMake(FLT_MAX, FLT_MAX) lineBreakMode:UILineBreakModeClip];
        CGFloat textWidth = suggestedSize.width;
        CGFloat totalWidth = textWidth + LEFT_BORDER + RIGHT_BORDER;

        // preload images
        sheet = [[Theme theme] stylesheetForKey:[NSString stringWithFormat:@"CustomSizedButtonView.%@.leftHighlighted", themeRef] retainStylesheet:YES overwriteStylesheet:YES error:nil];
        sheet = [[Theme theme] stylesheetForKey:[NSString stringWithFormat:@"CustomSizedButtonView.%@.rightHighlighted", themeRef] retainStylesheet:YES overwriteStylesheet:YES error:nil];
        sheet = [[Theme theme] stylesheetForKey:[NSString stringWithFormat:@"CustomSizedButtonView.%@.centerHighlighted", themeRef] retainStylesheet:YES overwriteStylesheet:YES error:nil];

        
        // left image , static size
        sheet = [[Theme theme] stylesheetForKey:[NSString stringWithFormat:@"CustomSizedButtonView.%@.left", themeRef] retainStylesheet:YES overwriteStylesheet:YES error:nil];
        CGRect frame = sheet.frame;
        self.left = [sheet makeImage];
        self.left.frame = frame;
        [self addSubview:self.left];
        
        CGFloat totalHeight = sheet.frame.size.height;

        
        // right image , static size
        sheet = [[Theme theme] stylesheetForKey:[NSString stringWithFormat:@"CustomSizedButtonView.%@.right", themeRef] retainStylesheet:YES overwriteStylesheet:YES error:nil];
        frame = sheet.frame;
        frame = CGRectMake(totalWidth - frame.size.width, 0, frame.size.width, frame.size.height);
        self.right = [sheet makeImage];
        self.right.frame = frame;
        [self addSubview:self.right];
        

        // frame
        self.frame = CGRectMake(0, 0, totalWidth, totalHeight);
        
        // center image, dynamic size
        sheet = [[Theme theme] stylesheetForKey:[NSString stringWithFormat:@"CustomSizedButtonView.%@.center", themeRef] retainStylesheet:YES overwriteStylesheet:YES error:nil];
        self.center = [[UIView alloc] init];
        self.center.frame = CGRectMake(left.frame.size.width, 0, totalWidth - left.frame.size.width - right.frame.size.width, totalHeight);
        self.center.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
        [self addSubview:self.center];
        
        // title
        sheet = [[Theme theme] stylesheetForKey:[NSString stringWithFormat:@"CustomSizedButtonView.%@.title", themeRef] retainStylesheet:YES overwriteStylesheet:YES error:nil];
        UILabel* label = [sheet makeLabel];
        label.frame = CGRectMake(LEFT_BORDER, 0, textWidth, totalHeight-2); // -2 is fine tuning for visual good result
        label.text = title;
        [self addSubview:label];
    }
    
    return self;
    
    
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // update GUI for "highlighted" state
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:[NSString stringWithFormat:@"CustomSizedButtonView.%@.leftHighlighted", themeRef] retainStylesheet:YES overwriteStylesheet:YES error:nil];
    self.left.image = [sheet image];

    sheet = [[Theme theme] stylesheetForKey:[NSString stringWithFormat:@"CustomSizedButtonView.%@.rightHighlighted", themeRef] retainStylesheet:YES overwriteStylesheet:YES error:nil];
    self.right.image = [sheet image];
    
    sheet = [[Theme theme] stylesheetForKey:[NSString stringWithFormat:@"CustomSizedButtonView.%@.centerHighlighted", themeRef] retainStylesheet:YES overwriteStylesheet:YES error:nil];
    self.center.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
    
    [super touchesBegan:touches withEvent:event];
}






- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // update GUI for "normal" state
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:[NSString stringWithFormat:@"CustomSizedButtonView.%@.left", themeRef] retainStylesheet:YES overwriteStylesheet:YES error:nil];
    self.left.image = [sheet image];
    
    sheet = [[Theme theme] stylesheetForKey:[NSString stringWithFormat:@"CustomSizedButtonView.%@.right", themeRef] retainStylesheet:YES overwriteStylesheet:YES error:nil];
    self.right.image = [sheet image];
    
    sheet = [[Theme theme] stylesheetForKey:[NSString stringWithFormat:@"CustomSizedButtonView.%@.center", themeRef] retainStylesheet:YES overwriteStylesheet:YES error:nil];
    self.center.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
    
    if (self.target)
        [self.target performSelector:self.action withObject:self];

    [super touchesEnded:touches withEvent:event];
}




@end
