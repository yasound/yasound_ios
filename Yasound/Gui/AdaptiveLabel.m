//
//  AdaptiveLabel.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 15/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "AdaptiveLabel.h"

@implementation AdaptiveLabel

- (id)init
{
    if (self = [super init])
    {
        _needAdapt = NO;
    }
    
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        _needAdapt = NO;
    }
    
    return self;
}


- (void)setText:(NSString *)text
{
    [super setText:text];
    [self adapt];
}

//- (void)setFont:(UIFont *)font
//{
//    [super setFont:font];
//
//    [self adapt];
//}


- (void)adapt
{

    /* This is where we define the ideal font that the Label wants to use.
     Use the font you want to use and the largest font size you want to use. */
    CGFloat fontSize = self.font.pointSize;
    UIFont* font = nil;

    int i;
    /* Time to calculate the needed font size.
     This for loop starts at the largest font size, and decreases by two point sizes (i=i-2)
     Until it either hits a size that will fit or hits the minimum size we want to allow (i > 10) */
    for(i = fontSize; i > 6; i--)
    {
        // Set the new font size.
        font = [self.font fontWithSize:i];
        // You can log the size you're trying: DLog(@"Trying size: %u", i);
        
        /* This step is important: We make a constraint box 
         using only the fixed WIDTH of the UILabel. The height will
         be checked later. */ 
        CGSize constraintSize = CGSizeMake(self.frame.size.width, MAXFLOAT);
        
        // This step checks how tall the label would be with the desired font.
        CGSize labelSize = [self.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        
        /* Here is where you use the height requirement!
         Set the value in the if statement to the height of your UILabel
         If the label fits into your required height, it will break the loop
         and use that font size. */
        if(labelSize.height <= self.frame.size.height)
            break;
    }
    // You can see what size the function is using by outputting: DLog(@"Best size is: %u", i);

    // Set the UILabel's font to the newly adjusted font.
    self.font = font;
}

@end
