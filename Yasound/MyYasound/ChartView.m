//
//  ChartView.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 25/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "ChartView.h"

#ifndef RGB
#define RGB(R,G,B) [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:1.0f]
#endif

#ifndef RGBA
#define RGBA(R,G,B,A) [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A/255.0f]
#endif



@implementation ChartView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.dataSource = self;
        
        NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numberFormatter setMinimumFractionDigits:0];
        [numberFormatter setMaximumFractionDigits:0];
        
        self.yValuesFormatter = numberFormatter;
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        
//        NSString *format = [dateFormatter dateFormat];
//        format = [format stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
//        format = [format stringByReplacingOccurrencesOfString:@"y" withString:@""];
        NSString* format = [NSString stringWithString:@"MM-dd"];
        [dateFormatter setDateFormat:format];
        
        self.xValuesFormatter = dateFormatter;
        
        [dateFormatter release];        
        [numberFormatter release];
        
        CGFloat value = 247.f / 255.f;
  self.backgroundColor = [UIColor colorWithRed:value green:value blue:value alpha:1];
        
//        self.plotColor = RGB(5, 141, 191); 
//        self.fillColor = RGB(5, 141, 191); 
//        self.spotColor = RGBA(0,0,0,128);
//        self.spotBorderColor = RGBA(255,255,255,128);
        self.spotColor = RGBA(200,200,200,128);
        self.spotBorderColor = RGBA(96,96,96,128);
//        self.backgroundColor = [UIColor redColor];
        
        self.drawAxisX = YES;
        self.drawAxisY = YES;
        self.drawGridX = NO;
        self.drawGridY = YES;
        
        self.xValuesColor = [UIColor grayColor];
        self.yValuesColor = [UIColor grayColor];
        
        self.gridXColor = [UIColor grayColor];
        self.gridYColor = [UIColor grayColor];
        
        self.drawInfo = NO;
        self.info = @"Load";
        self.infoColor = [UIColor grayColor];
        
        //When you need to update the data, make this call:
        [self reloadData];
    
    }
    return self;
}






#pragma mark protocol S7GraphViewDataSource

- (NSUInteger)graphViewNumberOfPlots:(S7GraphView *)graphView 
{
	/* Return the number of plots you are going to have in the view. 1+ */
	return 1;
}

- (NSArray *)graphViewXValues:(S7GraphView *)graphView 
{
	/* An array of objects that will be further formatted to be displayed on the X-axis.
	 The number of elements should be equal to the number of points you have for every plot. */
    //	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:101];
    //	for ( int i = -50 ; i <= 50 ; i ++ ) {
    //		[array addObject:[NSNumber numberWithInt:i]];	
    //	}
    //	return array;
    
	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:101];
	for ( int i = 0 ; i < 7 ; i ++ ) 
    {
		[array addObject:[NSDate date]];	
	}
	return array;
    
}

- (NSArray *)graphView:(S7GraphView *)graphView yValuesForPlot:(NSUInteger)plotIndex 
{
	/* Return the values for a specific graph. Each plot is meant to have equal number of points.
	 And this amount should be equal to the amount of elements you return from graphViewXValues: method. */
	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:101];

    [array addObject:[NSNumber numberWithInt:100]];
    [array addObject:[NSNumber numberWithInt:8]];
    [array addObject:[NSNumber numberWithInt:76]];
    [array addObject:[NSNumber numberWithInt:578]];
    [array addObject:[NSNumber numberWithInt:1087]];
    [array addObject:[NSNumber numberWithInt:720]];
    [array addObject:[NSNumber numberWithInt:486]];
	
	return array;
}


- (BOOL)graphView:(S7GraphView *)graphView shouldFillPlot:(NSUInteger)plotIndex
{
    return YES;
}





@end