//
//  ChartView.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 25/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "ChartView.h"

//#ifndef RGB
//#define RGB(R,G,B) [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:1.0f]
//#endif
//
//#ifndef RGBA
//#define RGBA(R,G,B,A) [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A/255.0f]
//#endif



@implementation ChartView

@synthesize dates = _dates;
@synthesize values = _values;


- (id)initWithFrame:(CGRect)frame minimalDisplay:(BOOL)minimalDisplay
{
    self = [super initWithFrame:frame minimalDisplay:minimalDisplay];
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
        
        NSString* format = [NSString stringWithString:@"MM/dd"];
        [dateFormatter setDateFormat:format];
        
        self.xValuesFormatter = dateFormatter;
        
        [dateFormatter release];        
        [numberFormatter release];
        
//        CGFloat value = 247.f / 255.f;
//        self.backgroundColor = [UIColor colorWithRed:value green:value blue:value alpha:1];
        self.backgroundColor = [UIColor clearColor];
        
//        self.plotColor = RGB(5, 141, 191); 
//        self.fillColor = RGB(5, 141, 191); 
        self.spotColor = RGB(47,174,247);
        self.spotBorderColor = RGB(21,130,192);
//        self.fillColor = [UIColor clearColor];

//        self.backgroundColor = [UIColor redColor];
        
        self.drawAxisX = YES;
        self.drawAxisY = YES;
        self.drawGridX = NO;
        self.drawGridY = YES;
        
        self.xValuesColor = RGB(128,128,128);
        self.yValuesColor = RGB(128,128,128);

        
        self.gridXColor = RGB(64, 64, 64);
        self.gridYColor = RGB(64, 64, 64);
        
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
    return _dates;
    
	/* An array of objects that will be further formatted to be displayed on the X-axis.
	 The number of elements should be equal to the number of points you have for every plot. */
    //	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:101];
    //	for ( int i = -50 ; i <= 50 ; i ++ ) {
    //		[array addObject:[NSNumber numberWithInt:i]];	
    //	}
    //	return array;
    
//	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:101];
//	for ( int i = 0 ; i < 7 ; i ++ ) 
//    {
//		[array addObject:[NSDate date]];	
//	}
//	return array;
    
}

- (NSArray *)graphView:(S7GraphView *)graphView yValuesForPlot:(NSUInteger)plotIndex 
{
    return _values;
    
//	/* Return the values for a specific graph. Each plot is meant to have equal number of points.
//	 And this amount should be equal to the amount of elements you return from graphViewXValues: method. */
//	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:101];
//
//    //EXEMPLE 1
////    [array addObject:[NSNumber numberWithInt:100]];
////    [array addObject:[NSNumber numberWithInt:8]];
////    [array addObject:[NSNumber numberWithInt:76]];
////    [array addObject:[NSNumber numberWithInt:578]];
////    [array addObject:[NSNumber numberWithInt:1087]];
////    [array addObject:[NSNumber numberWithInt:720]];
////    [array addObject:[NSNumber numberWithInt:486]];
//
//    //EXEMPLE 2
//    [array addObject:[NSNumber numberWithInt:100]];
//    [array addObject:[NSNumber numberWithInt:200]];
//    [array addObject:[NSNumber numberWithInt:76]];
//    [array addObject:[NSNumber numberWithInt:256]];
//    [array addObject:[NSNumber numberWithInt:23]];
//    [array addObject:[NSNumber numberWithInt:189]];
//    [array addObject:[NSNumber numberWithInt:56]];
//	
//    
//	return array;
}


- (BOOL)graphView:(S7GraphView *)graphView shouldFillPlot:(NSUInteger)plotIndex
{
    return YES;
}





@end