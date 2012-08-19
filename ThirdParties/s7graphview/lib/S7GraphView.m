//
//  S7GraphView.m
//  S7Touch
//
//  Created by Aleks Nesterow on 9/27/09.
//  aleks.nesterow@gmail.com
//  
//  Thanks to http://snobit.habrahabr.ru/ for releasing sources for his
//  Cocoa component named GraphView.
//  
//  Copyright © 2009, 7touchGroup, Inc.
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  * Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  * Neither the name of the 7touchGroup, Inc. nor the
//  names of its contributors may be used to endorse or promote products
//  derived from this software without specific prior written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY 7touchGroup, Inc. "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL 7touchGroup, Inc. BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//  

#import "S7GraphView.h"

#define FONT_SIZE_INFO 9.0f
#define FONT_SIZE_VALUES 9.0f

#define MARGIN_TOP 4.0f
#define MARGIN_RIGHT 12.0f

#define OFFSET_X_MIN 10.f
#define OFFSET_X_STEP 8.f

#define AXIS_Y_WIDTH_STEP 7.f

#define OFFSET_Y_MIN 22.0f
#define AXIS_X_OFFSET 16.f
#define AXIS_X_WIDTH 54.f

#define SPOT_RADIUS 2.0f


@interface S7GraphView (PrivateMethods)

- (void)initializeComponent;

@end

@implementation S7GraphView

+ (UIColor *)colorByIndex:(NSInteger)index {
	
	UIColor *color;
	
	switch (index) {
		case 0: color = RGB(5, 141, 191);
			break;
		case 1: color = RGB(80, 180, 50);
			break;		
		case 2: color = RGB(255, 102, 0);
			break;
		case 3: color = RGB(255, 158, 1);
			break;
		case 4: color = RGB(252, 210, 2);
			break;
		case 5: color = RGB(248, 255, 1);
			break;
		case 6: color = RGB(176, 222, 9);
			break;
		case 7: color = RGB(106, 249, 196);
			break;
		case 8: color = RGB(178, 222, 255);
			break;
		case 9: color = RGB(4, 210, 21);
			break;
		default: color = RGB(204, 204, 204);
			break;
	}
	
	return color;
}

@synthesize dataSource = _dataSource, xValuesFormatter = _xValuesFormatter, yValuesFormatter = _yValuesFormatter;
@synthesize drawAxisX = _drawAxisX, drawAxisY = _drawAxisY, drawGridX = _drawGridX, drawGridY = _drawGridY;
@synthesize xValuesColor = _xValuesColor, yValuesColor = _yValuesColor, gridXColor = _gridXColor, gridYColor = _gridYColor;
@synthesize drawInfo = _drawInfo, info = _info, infoColor = _infoColor;
@synthesize plotColor;
@synthesize fillColor;
@synthesize spotColor;
@synthesize spotBorderColor;


- (id)initWithFrame:(CGRect)frame minimalDisplay:(BOOL)minimalDisplay
{
    CGRect frameWithSpacing = CGRectMake(frame.origin.x, frame.origin.y + MARGIN_TOP, frame.size.width, frame.size.height - MARGIN_TOP);
    
    if (self = [super initWithFrame:frameWithSpacing]) 
    {
        _minimalDisplay = minimalDisplay;
        
        [self initializeComponent];
    
        self.plotColor = RGB(5, 141, 191); 
        self.fillColor = RGB(255,0,255);
        self.spotColor = RGB(5, 141, 191);
        self.spotBorderColor = RGB(5, 141, 191); 
    }
	
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	
	if (self = [super initWithCoder:decoder]) {
		[self initializeComponent];
	}
	
	return self;
}

- (void)dealloc {
	
	[_xValuesFormatter release];
	[_yValuesFormatter release];
	
	[_xValuesColor release];
	[_yValuesColor release];
	
	[_gridXColor release];
	[_gridYColor release];
	
	[_info release];
	[_infoColor release];
	
	[super dealloc];
}

- (void)drawRect:(CGRect)rect 
{
	
	CGContextRef c = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(c, self.backgroundColor.CGColor);
	CGContextFillRect(c, rect);
	
	NSUInteger numberOfPlots = [self.dataSource graphViewNumberOfPlots:self];
	
	if (!numberOfPlots) {
		return;
	}
	
//	CGFloat offsetX = _drawAxisY ? 60.0f : 10.0f;
    //LBDEBUG offsetY : 30 -> 24
//	CGFloat offsetX = _drawAxisY ? 10.0f : 10.0f;
	CGFloat offsetX = OFFSET_X_MIN;
//	CGFloat offsetY = (_drawAxisX || _drawInfo) ? 24.0f : 10.0f;
	CGFloat offsetY = OFFSET_Y_MIN;
	
	CGFloat minY = 0.0;
	CGFloat maxY = 0.0;
	
	UIFont *font = [UIFont systemFontOfSize:FONT_SIZE_VALUES];
	
	for (NSUInteger plotIndex = 0; plotIndex < numberOfPlots; plotIndex++) {
		
		NSArray *values = [self.dataSource graphView:self yValuesForPlot:plotIndex];
		
		for (NSUInteger valueIndex = 0; valueIndex < values.count; valueIndex++) 
        {
            CGFloat yValue = [[values objectAtIndex:valueIndex] floatValue];
            
			if (yValue > maxY) 
            {
				maxY = [[values objectAtIndex:valueIndex] floatValue];
			}
		}
	}

	//LBDEBUG
//	if (maxY < 100) {
    
//    maxY = ceil(maxY + (maxY / 2.f));
    maxY = ceil(maxY);
    
    //LBDEBUG
    // update offsetX, depending on maxY (to have enough space to write the Y values)
    CGFloat tmp = maxY / 10;
    while (tmp > 1)
    {
        offsetX += OFFSET_X_STEP;
        tmp = tmp / 10;
    }
    
    // update label width, depending on the values to write
    CGFloat axisYLabelWidth = 8.0f;
    tmp = maxY / 10;
    while (tmp > 1)
    {
        axisYLabelWidth += AXIS_Y_WIDTH_STEP;
        tmp = tmp / 10;
    }

    //LBDEBUG
//    if ((maxY > 10) && (maxY < 100)) {
//		maxY = ceil(maxY / 10) * 10;
//	} 
//	
//	if (maxY > 100 && maxY < 1000) {
//		maxY = ceil(maxY / 100) * 100;
//	} 
//	
//	if (maxY > 1000 && maxY < 10000) {
//		maxY = ceil(maxY / 1000) * 1000;
//	}
//	
//	if (maxY > 10000 && maxY < 100000) {
//		maxY = ceil(maxY / 10000) * 10000;
//	}
	
	CGFloat step = (maxY - minY) / 5;
    // LBDEBUG
//	CGFloat stepY = (self.frame.size.height - (offsetY*2)) / maxY;
	CGFloat stepY = (self.frame.size.height - (offsetY)) / maxY;
    
    NSArray* values = [self.dataSource graphView:self yValuesForPlot:0];
    NSArray *sortedValuesForAxisY;
    sortedValuesForAxisY = [values sortedArrayUsingComparator:^(id a, id b) 
    {
        NSInteger first = [a integerValue];
        NSInteger second = [b integerValue];
        return (first > second);
    }];
	
	for (NSUInteger i = 0; i < 6; i++) {

		//LBDEBUG
//		NSUInteger y = (i * step) * stepY;
//		NSUInteger value = i * step;
		NSUInteger y = (i * step) * stepY;
		NSUInteger value = i * step;
		
		if (_drawGridY) {
			
			CGFloat lineDash[2];
			lineDash[0] = 6.0f;
			lineDash[1] = 6.0f;
			
			CGContextSetLineDash(c, 0.0f, lineDash, 2);
			CGContextSetLineWidth(c, 0.05f);
			
			CGPoint startPoint = CGPointMake(offsetX, self.frame.size.height - y - offsetY);
            //LBDEBUG
//			CGPoint endPoint = CGPointMake(self.frame.size.width - offsetX, self.frame.size.height - y - offsetY);
			CGPoint endPoint = CGPointMake(self.frame.size.width - MARGIN_RIGHT, self.frame.size.height - y - offsetY);
			
			CGContextMoveToPoint(c, startPoint.x, startPoint.y);
			CGContextAddLineToPoint(c, endPoint.x, endPoint.y);
			CGContextClosePath(c);
			
			CGContextSetStrokeColorWithColor(c, self.gridYColor.CGColor);
			CGContextStrokePath(c);
		}

		//LBDEBUG
//		if (i > 0 && _drawAxisY) 
        //ICI
//        if (!(i & 1) && _drawAxisY) 
        // draw axisY here, only if it's not in minimal display
        if (_drawAxisY && !_minimalDisplay)
        {

			//LBDEBUG
			NSNumber *valueToFormat = [NSNumber numberWithInt:value];
            
			//NSNumber *valueToFormat = [NSNumber numberWithInt:[[values objectAtIndex:i] intValue]];
			NSString *valueString;
			
			if (_yValuesFormatter) {
				valueString = [_yValuesFormatter stringForObjectValue:valueToFormat];
			} else {
				valueString = [valueToFormat stringValue];
			}
			
			[self.yValuesColor set];
            //LBDEBUG
//			CGRect valueStringRect = CGRectMake(0.0f, self.frame.size.height - y - offsetY, 50.0f, 20.0f);
            
            
			CGRect valueStringRect = CGRectMake(0.0f, self.frame.size.height - y - offsetY - (FONT_SIZE_INFO-2), axisYLabelWidth, FONT_SIZE_INFO+2);
			
			[valueString drawInRect:valueStringRect withFont:font
					  lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
		}
	}
    
    
    
    // minidisplay : only display min and max values
    if (_drawAxisY && _minimalDisplay)
    {
        int int_minY = (int)minY;
        int int_maxY = (int)maxY;
        NSNumber* num_minY = [NSNumber numberWithInt:int_minY];
        NSNumber* num_maxY = [NSNumber numberWithInt:int_maxY];
        NSString* str_minY;
        NSString* str_maxY;
            
        if (_yValuesFormatter) 
        {
            str_minY = [_yValuesFormatter stringForObjectValue:num_minY];
            str_maxY = [_yValuesFormatter stringForObjectValue:num_maxY];
        }
        else 
        {
            str_minY = [num_minY stringValue];
            str_maxY = [num_maxY stringValue];
        }
            
        [self.yValuesColor set];
        
        CGRect rect_minY = CGRectMake(0.0f, self.frame.size.height - offsetY - (FONT_SIZE_INFO-2), axisYLabelWidth, FONT_SIZE_INFO+2);
        CGRect rect_maxY = CGRectMake(0.0f, 0 - (FONT_SIZE_INFO-2), axisYLabelWidth, FONT_SIZE_INFO+2);
        
        [str_minY drawInRect:rect_minY withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
        [str_maxY drawInRect:rect_maxY withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
    }

    
	
	NSUInteger maxStep;
	
	NSArray *xValues = [self.dataSource graphViewXValues:self];
	NSUInteger xValuesCount = xValues.count;
	
	if (xValuesCount > 5) {
		
		NSUInteger stepCount = 5;
		NSUInteger count = xValuesCount - 1;
		
		for (NSUInteger i = 4; i < 8; i++) {
			if (count % i == 0) {
				stepCount = i;
			}
		}
		
		step = xValuesCount / stepCount;
		maxStep = stepCount + 1;
		
	} else {
		
		step = 1;
		maxStep = xValuesCount;
	}

	//LBDEBUG
//	CGFloat stepX = (self.frame.size.width - (offsetX * 2)) / (xValuesCount - 1);
	CGFloat stepX = (self.frame.size.width - (offsetX + MARGIN_RIGHT)) / (xValuesCount - 1);
//	CGFloat stepX = (self.frame.size.width - (offsetX * 2)) / (xValuesCount );
	
	for (NSUInteger i = 0; i < maxStep; i++) {
		
		NSUInteger x = (i * step) * stepX;
		
        //LBDEBUG
//		if (x > self.frame.size.width - (offsetX * 2)) {
//			x = self.frame.size.width - (offsetX * 2);
//		}
		if (x > self.frame.size.width - (offsetX + MARGIN_RIGHT)) {
			x = self.frame.size.width - (offsetX + MARGIN_RIGHT);
		}
		
		NSUInteger index = i * step;
		
		if (index >= xValuesCount) {
			index = xValuesCount - 1;
		}
		
		if (_drawGridX) {
			
			CGFloat lineDash[2];
			
			lineDash[0] = 6.0f;
			lineDash[1] = 6.0f;
			
			CGContextSetLineDash(c, 0.0f, lineDash, 2);
			CGContextSetLineWidth(c, 0.1f);
			
			CGPoint startPoint = CGPointMake(x + offsetX, offsetY);
			CGPoint endPoint = CGPointMake(x + offsetX, self.frame.size.height - offsetY);
			
			CGContextMoveToPoint(c, startPoint.x, startPoint.y);
			CGContextAddLineToPoint(c, endPoint.x, endPoint.y);
			CGContextClosePath(c);
			
			CGContextSetStrokeColorWithColor(c, self.gridXColor.CGColor);
			CGContextStrokePath(c);
		}
		
		if (_drawAxisX) {
			
			id valueToFormat = [xValues objectAtIndex:index];
            //DLog(@"debug %@", valueToFormat);
			NSString *valueString;
			
			if (_xValuesFormatter) {
				valueString = [_xValuesFormatter stringForObjectValue:valueToFormat];
			} else {
				valueString = [NSString stringWithFormat:@"%@", valueToFormat];
			}
			
			[self.xValuesColor set];
			[valueString drawInRect:CGRectMake(x, self.frame.size.height - AXIS_X_OFFSET, AXIS_X_WIDTH, 20.0f) withFont:font
					  lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
		}
	}

	//LBDEBUG
//	stepX = (self.frame.size.width - (offsetX * 2)) / (xValuesCount - 1);
	stepX = (self.frame.size.width - (offsetX + MARGIN_RIGHT)) / (xValuesCount - 1);
	
	CGContextSetLineDash(c, 0, NULL, 0);
	
	for (NSUInteger plotIndex = 0; plotIndex < numberOfPlots; plotIndex++) {
		
		NSArray *values = [self.dataSource graphView:self yValuesForPlot:plotIndex];
		BOOL shouldFill = NO;
		BOOL shouldDrawSpot = YES;
		
		if ([self.dataSource respondsToSelector:@selector(graphView:shouldFillPlot:)]) {
			shouldFill = [self.dataSource graphView:self shouldFillPlot:plotIndex];
		}
		
        //LBDEBUG
		CGColorRef plotColor = self.plotColor.CGColor;
		CGColorRef fillColor = [UIColor clearColor].CGColor;
		CGColorRef spotColor = self.spotColor.CGColor;
		CGColorRef spotBorderColor = self.spotBorderColor.CGColor;
		
		for (NSUInteger valueIndex = 0; valueIndex < values.count; valueIndex++) 
        {
			
			NSUInteger x = valueIndex * stepX;
			NSUInteger y = [[values objectAtIndex:valueIndex] intValue] * stepY;
			
			CGContextSetLineWidth(c, 1.5f);
			
			CGPoint startPoint = CGPointMake(x + offsetX, self.frame.size.height - y - offsetY);
			
            if (valueIndex == values.count - 1)
            {
                x = (valueIndex) * stepX;
                y = [[values objectAtIndex:valueIndex] intValue] * stepY;
            }
            else
            {
                x = (valueIndex + 1) * stepX;
                y = [[values objectAtIndex:valueIndex + 1] intValue] * stepY;
            }
			
            
			CGPoint endPoint;
            
            if (valueIndex == values.count - 1)
                endPoint = CGPointMake(x + offsetX, self.frame.size.height - y - offsetY);
            else
                endPoint = CGPointMake(x + offsetX, self.frame.size.height - y - offsetY);
			
			CGContextMoveToPoint(c, startPoint.x, startPoint.y);
			CGContextAddLineToPoint(c, endPoint.x, endPoint.y);
			CGContextClosePath(c);
			
			CGContextSetStrokeColorWithColor(c, plotColor);
			CGContextStrokePath(c);
			
			if (shouldFill) 
            {
				
				CGContextMoveToPoint(c, startPoint.x, self.frame.size.height - offsetY);
				CGContextAddLineToPoint(c, startPoint.x, startPoint.y);
				CGContextAddLineToPoint(c, endPoint.x, endPoint.y);
				CGContextAddLineToPoint(c, endPoint.x, self.frame.size.height - offsetY);
				CGContextClosePath(c);
				
				CGContextSetFillColorWithColor(c, fillColor);
				CGContextFillPath(c);
			}
            
            // draw spot
            if (shouldDrawSpot)
            {
                CGContextSetLineWidth(c, 1.0f);
                CGRect spotRect = CGRectMake(startPoint.x -SPOT_RADIUS, startPoint.y -SPOT_RADIUS, SPOT_RADIUS*2, SPOT_RADIUS*2);
                
                CGContextSetFillColorWithColor(c, spotColor);
                CGContextFillEllipseInRect(c, spotRect);
                CGContextSetStrokeColorWithColor(c, spotBorderColor);
                CGContextStrokeEllipseInRect(c, spotRect);
            }
            
            
		}
	}
	
	if (_drawInfo) 
    {
		
		font = [UIFont boldSystemFontOfSize:FONT_SIZE_INFO];
		[self.infoColor set];
		[_info drawInRect:CGRectMake(0.0f, 5.0f, self.frame.size.width, 20.0f) withFont:font
			lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
	}
}

- (void)reloadData {
	
	[self setNeedsDisplay];
}

#pragma mark PrivateMethods

- (void)initializeComponent {
	
	_drawAxisX = YES;
	_drawAxisY = YES;
	_drawGridX = YES;
	_drawGridY = YES;
	
	_xValuesColor = [[UIColor blackColor] retain];
	_yValuesColor = [[UIColor blackColor] retain];
	
	_gridXColor = [[UIColor blackColor] retain];
	_gridYColor = [[UIColor blackColor] retain];
	
	_drawInfo = NO;
	_infoColor = [[UIColor blackColor] retain];
}

@end
