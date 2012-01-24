

//  DateAdditions.m
//
//  Created by Julien on 28/05/09.
//  Copyright 2009 Julien Quéré - Webd.fr. All rights reserved.
//

#import "DateAdditions.h"


@implementation NSDate (NSDateAdditions)

-(BOOL) isLaterThanOrEqualTo:(NSDate*)date {
	return !([self compare:date] == NSOrderedAscending);
}

-(BOOL) isEarlierThanOrEqualTo:(NSDate*)date {
	return !([self compare:date] == NSOrderedDescending);
}
-(BOOL) isLaterThan:(NSDate*)date {
	return ([self compare:date] == NSOrderedDescending);
    
}
-(BOOL) isEarlierThan:(NSDate*)date {
	return ([self compare:date] == NSOrderedAscending);
}

@end